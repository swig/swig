/* -----------------------------------------------------------------------------
 * hash.c
 *
 *     Implements a simple hash table object.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "dohint.h"

/* Hash node */
typedef struct HashNode {
    DOH                  *key;
    DOH                  *object;
    struct HashNode     *next;
} HashNode;

/* Hash object */
typedef struct Hash {
  DOH  *file;
  int   line;
  HashNode          **hashtable;
  int                 hashsize;
  int                 currentindex;
  int                 nitems;
  HashNode           *current;
} Hash;

/* Key interning structure */
typedef struct KeyValue {
    char   *cstr;
    DOH    *sstr;
    struct KeyValue *left;
    struct KeyValue *right;
} KeyValue;

static KeyValue *root = 0;

/* Find or create a key in the interned key table */
static DOH *find_key (DOH *doh_c) {
  char *c = (char *) doh_c;
  KeyValue *r, *s;
  int d = 0;
  r = root;
  s = 0;
  while (r) {
    s = r;
    d = strcmp(r->cstr,c);
    if (d == 0) return r->sstr;
    if (d < 0) r = r->left;
    else r = r->right;
  }
  /*  fprintf(stderr,"Interning '%s'\n", c);*/
  r = (KeyValue *) DohMalloc(sizeof(KeyValue));
  r->cstr = (char *) DohMalloc(strlen(c)+1);
  strcpy(r->cstr,c);
  r->sstr = NewString(c);
  DohIntern(r->sstr);
  r->left = 0;
  r->right = 0;
  if (!s) { root = r; }
  else {
    if (d < 0) s->left = r;
    else s->right = r;
  }
  return r->sstr;
}

#define HASH_INIT_SIZE   7

/* Create a new hash node */
static HashNode *NewNode(DOH *k, void *obj) {
    HashNode *hn = (HashNode *) DohMalloc(sizeof(HashNode));
    hn->key = k;
    Incref(hn->key);
    hn->object = obj;
    Incref(obj);
    hn->next = 0;
    return hn;
}

/* Delete a hash node */
static void DelNode(HashNode *hn) {
    Delete(hn->key);
    Delete(hn->object);
    DohFree(hn);
}

/* -----------------------------------------------------------------------------
 * DelHash()
 *
 * Delete a hash table.
 * ----------------------------------------------------------------------------- */

static void
DelHash(DOH *ho) {
    Hash *h = (Hash *) ObjData(ho);
    HashNode *n,*next;
    int i;

    for (i = 0; i < h->hashsize; i++) {
	if ((n = h->hashtable[i])) {
	    while (n) {
		next = n->next;
		DelNode(n);
		n = next;
	    }
	}
    }
    DohFree(h->hashtable);
    h->hashtable = 0;
    h->hashsize = 0;
    DohFree(h);
}

/* -----------------------------------------------------------------------------
 * Hash_clear()
 *
 * Clear all of the entries in the hash table.
 * ----------------------------------------------------------------------------- */

static void
Hash_clear(DOH *ho) {
    Hash *h = (Hash *) ObjData(ho);
    HashNode *n,*next;
    int i;

    for (i = 0; i < h->hashsize; i++) {
	if ((n = h->hashtable[i])) {
	    while (n) {
		next = n->next;
		DelNode(n);
		n = next;
	    }
	}
	h->hashtable[i] = 0;
    }
    h->nitems = 0;
}

/* resize the hash table */
static void resize(Hash *h) {
    HashNode   *n, *next, **table;
    int         oldsize, newsize;
    int         i, p, hv;

    if (h->nitems < 2*h->hashsize) return;

    /* Too big. We have to rescale everything now */
    oldsize = h->hashsize;

    /* Calculate a new size */
    newsize = 2*oldsize+1;
    p = 3;
    while (p < (newsize >> 1)) {
	if (((newsize/p)*p) == newsize) {
	    newsize+=2;
	    p = 3;
	    continue;
	}
	p = p + 2;
    }

    table = (HashNode **) DohMalloc(newsize*sizeof(HashNode *));
    for (i = 0; i < newsize; i++ ) {
	table[i] = 0;
    }

    /* Walk down the old set of nodes and re-place */
    h->hashsize = newsize;
    for (i = 0; i < oldsize; i++) {
	n = h->hashtable[i];
	while (n) {
	    hv = Hashval(n->key) % newsize;
	    next = n->next;
	    n->next = table[hv];
	    table[hv] = n;
	    n = next;
	}
    }
    DohFree(h->hashtable);
    h->hashtable = table;
}

/* -----------------------------------------------------------------------------
 * Hash_setattr()
 *
 * Set an attribute in the hash table.  Deletes the existing entry if it already
 * exists.
 * ----------------------------------------------------------------------------- */

static int
Hash_setattr(DOH *ho, DOH *k, DOH *obj) {
    int hv;
    HashNode *n, *prev;
    Hash *h = (Hash *) ObjData(ho);

    if (!obj) return 0;
    if (!DohCheck(k)) k = find_key(k);
    if (!DohCheck(obj)) {
      obj = NewString((char *) obj);
      Decref(obj);
    }
    hv = (Hashval(k)) % h->hashsize;
    n = h->hashtable[hv];
    prev = 0;
    while (n) {
      if (Cmp(n->key,k) == 0) {
	HashNode *nn;
	if (prev) {
	  prev->next = n->next;
	} else {
	  h->hashtable[hv] = n->next;
	}
	nn = n->next;
	DelNode(n);
	h->nitems--;
	n = nn;
      } else {
	prev = n;
	n = n->next;
      }
    }
    /* Add this to the table */
    n = NewNode(k,obj);
    if (prev) prev->next = n;
    else h->hashtable[hv] = n;
    h->nitems++;
    resize(h);
    return 0;
}

/* -----------------------------------------------------------------------------
 * Hash_getattr()
 *
 * Get an attribute from the hash table. Returns 0 if it doesn't exist.
 * ----------------------------------------------------------------------------- */

static DOH *
Hash_getattr(DOH *ho, DOH *k) {
    int hv;
    HashNode *n;
    Hash *h = (Hash *) ObjData(ho);

    if (!DohCheck(k)) k = find_key(k);
    hv = Hashval(k) % h->hashsize;
    n = h->hashtable[hv];
    while (n) {
      if (Cmp(n->key, k) == 0) return n->object;
      n = n->next;
    }
    return 0;
}

/* -----------------------------------------------------------------------------
 * Hash_delattr()
 *
 * Delete an object from the hash table.
 * ----------------------------------------------------------------------------- */

static int
Hash_delattr(DOH *ho, DOH *k) {
    HashNode *n, *prev;
    int hv;
    Hash *h = (Hash *) ObjData(ho);

    if (!DohCheck(k)) k = find_key(k);
    hv = Hashval(k) % h->hashsize;
    n = h->hashtable[hv];
    prev = 0;
    while (n) {
	if (Cmp(n->key, k) == 0) {
	    /* Found it, kill it */
	    if (prev) {
		prev->next = n->next;
	    } else {
		h->hashtable[hv] = n->next;
	    }
	    DelNode(n);
	    h->nitems--;
	    return 1;
	}
	prev = n;
	n = n->next;
    }
    return 0;
}

/* General purpose iterators */
static HashNode *
hash_first(DOH *ho) {
    Hash *h = (Hash *) ObjData(ho);
    h->currentindex = 0;
    h->current = 0;
    while (!h->hashtable[h->currentindex] && (h->currentindex < h->hashsize))
	h->currentindex++;
    if (h->currentindex >= h->hashsize) return 0;
    h->current = h->hashtable[h->currentindex];
    return h->current;
}

static HashNode *
hash_next(DOH *ho) {
    Hash *h = (Hash *) ObjData(ho);
    if (h->currentindex < 0) return hash_first(h);

    /* Try to move to the next entry */
    h->current = h->current->next;
    if (h->current) {
	return h->current;
    }
    h->currentindex++;
    while ((h->currentindex < h->hashsize) && !h->hashtable[h->currentindex])
	h->currentindex++;
    if (h->currentindex >= h->hashsize) return 0;
    h->current = h->hashtable[h->currentindex];
    return h->current;
}

/* -----------------------------------------------------------------------------
 * Hash_firstkey()
 *
 * Return first hash-table key.
 * ----------------------------------------------------------------------------- */

static DOH *
Hash_firstkey(DOH *ho) {
    HashNode *hn = hash_first(ho);
    if (hn) return hn->key;
    return 0;
}

/* -----------------------------------------------------------------------------
 * Hash_nextkey()
 *
 * Return next hash table key.
 * ----------------------------------------------------------------------------- */

static DOH *
Hash_nextkey(DOH *ho) {
    HashNode *hn = hash_next(ho);
    if (hn) return hn->key;
    return 0;
}

/* -----------------------------------------------------------------------------
 * Hash_str()
 *
 * Create a string representation of a hash table (mainly for debugging).
 * ----------------------------------------------------------------------------- */

static DOH *
Hash_str(DOH *ho) {
    int i;
    HashNode *n;
    DOH *s;
    Hash *h = (Hash *) ObjData(ho);

    s = NewString("");
    if (ObjGetMark(ho)) {
      Printf(s,"Hash(0x%x)",ho);
      return s;
    }
    ObjSetMark(ho,1);
    Printf(s,"Hash {\n");
    for (i = 0; i < h->hashsize; i++) {
	n = h->hashtable[i];
	while (n) {
	    Printf(s,"   '%s' : %s, \n", n->key, n->object);
	    n = n->next;
	}
    }
    Printf(s,"}\n");
    ObjSetMark(ho,0);
    return s;
}

/* -----------------------------------------------------------------------------
 * Hash_len()
 *
 * Return number of entries in the hash table.
 * ----------------------------------------------------------------------------- */

static int
Hash_len(DOH *ho) {
  Hash *h = (Hash *) ObjData(ho);
  return h->nitems;
}

/* -----------------------------------------------------------------------------
 * Hash_keys(DOH *)
 *
 * Return a list of keys
 * ----------------------------------------------------------------------------- */
DOH *
Hash_keys(DOH *so) {
  DOH *keys;
  DOH *k;

  keys = NewList();
  k = Firstkey(so);
  while (k) {
    Append(keys,k);
    k = Nextkey(so);
  }
  /*   List_sort(keys); */
  return keys;
}

/* -----------------------------------------------------------------------------
 * CopyHash()
 *
 * Make a copy of a hash table.  Note: this is a shallow copy.
 * ----------------------------------------------------------------------------- */

static DOH *
CopyHash(DOH *ho) {
    Hash *h, *nh;
    HashNode *n;
    int   i;
    h = (Hash *) ObjData(ho);
    nh = (Hash *) DohMalloc(sizeof(Hash));
    nh->hashsize = h->hashsize;
    nh->hashtable = (HashNode **) DohMalloc(nh->hashsize*sizeof(HashNode *));
    for (i = 0; i < nh->hashsize; i++) {
	nh->hashtable[i] = 0;
    }
    nh->currentindex = -1;
    nh->current = 0;
    nh->nitems = 0;
    nh->line = h->line;
    nh->file = h->file;
    if (nh->file) Incref(nh->file);

    for (i = 0; i < h->hashsize; i++) {
	if ((n = h->hashtable[i])) {
	    while (n) {
		Hash_setattr(nh, n->key, n->object);
		n = n->next;
	    }
	}
    }
    return DohObjMalloc(DOHTYPE_HASH, nh);
}



void Hash_setfile(DOH *ho, DOH *file) {
  DOH *fo;
  Hash *h = (Hash *) ObjData(ho);

  if (!DohCheck(file)) {
    fo = NewString(file);
    Decref(fo);
  } else fo = file;
  Incref(fo);
  Delete(h->file);
  h->file = fo;
}

DOH *Hash_getfile(DOH *ho) {
  Hash *h = (Hash *) ObjData(ho);
  return h->file;
}

void Hash_setline(DOH *ho, int line) {
  Hash *h = (Hash *) ObjData(ho);
  h->line = line;
}

int Hash_getline(DOH *ho) {
  Hash *h = (Hash *) ObjData(ho);
  return h->line;
}

/* -----------------------------------------------------------------------------
 * type information
 * ----------------------------------------------------------------------------- */

static DohHashMethods HashHashMethods = {
  Hash_getattr,
  Hash_setattr,
  Hash_delattr,
  Hash_firstkey,
  Hash_nextkey,
};

static DohObjInfo HashType = {
    "Hash",          /* objname */
    DelHash,         /* doh_del */
    CopyHash,        /* doh_copy */
    Hash_clear,      /* doh_clear */
    Hash_str,        /* doh_str */
    0,               /* doh_data */
    0,               /* doh_dump */
    Hash_len,        /* doh_len */
    0,               /* doh_hash    */
    0,               /* doh_cmp */
    Hash_setfile,               /* doh_setfile */
    Hash_getfile,               /* doh_getfile */
    Hash_setline,               /* doh_setline */
    Hash_getline,               /* doh_getline */
    &HashHashMethods, /* doh_mapping */
    0,                /* doh_sequence */
    0,                /* doh_file */
    0,                /* doh_string */
    0,                /* doh_positional */
    0,
};

/* -----------------------------------------------------------------------------
 * NewHash()
 *
 * Create a new hash table.
 * ----------------------------------------------------------------------------- */

DOH *
NewHash() {
    Hash *h;
    int   i;
    static int init = 0;
    if (!init) {
      DohRegisterType(DOHTYPE_HASH, &HashType);
      init = 1;
    }
    h = (Hash *) DohMalloc(sizeof(Hash));
    h->hashsize = HASH_INIT_SIZE;
    h->hashtable = (HashNode **) DohMalloc(h->hashsize*sizeof(HashNode *));
    for (i = 0; i < h->hashsize; i++) {
	h->hashtable[i] = 0;
    }
    h->currentindex = -1;
    h->current = 0;
    h->nitems = 0;
    h->file = 0;
    h->line = 0;
    return DohObjMalloc(DOHTYPE_HASH,h);
}
