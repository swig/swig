/****************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 ****************************************************************************/

#include "doh.h"

/***********************************************************************
 * $Header$
 *
 * hash.c
 *
 * Hash table implementation.
 ***********************************************************************/

/* Hash node */
typedef struct HashNode {
    DOH                  *key;            
    DOH                  *object;
    struct HashNode     *next;
} HashNode;

/* Hash object */
typedef struct Hash {
    DOHCOMMON;
    HashNode          **hashtable;
    int                 hashsize;
    int                 currentindex;
    int                 nitems;
    HashNode           *current;
} Hash;

/* Forward references */
DOH    *CopyHash(DOH *h);
void   DelHash(DOH *h);
void   Hash_clear(DOH *);
int    Hash_setattr(DOH *, DOH *k, DOH *obj);
DOH    *Hash_getattr(DOH *h, DOH *k);
int     Hash_delattr(DOH *h, DOH *k);
DOH    *Hash_firstkey(DOH *h);
DOH    *Hash_nextkey(DOH *h);
DOH    *Hash_str(DOH *h);
int    Hash_len(DOH *h);

#define HASH_INIT_SIZE   7

static HashNode *NewNode(DOH *k, void *obj) 
{
    HashNode *hn = (HashNode *) DohMalloc(sizeof(HashNode));
    hn->key = k;
    Incref(hn->key);
    hn->object = obj;
    Incref(obj);
    hn->next = 0;
    return hn;
}

static void DelNode(HashNode *hn) 
{
    Delete(hn->key);
    Delete(hn->object);
    DohFree(hn);
}


static DohMappingMethods HashMappingMethods = {
  Hash_getattr,
  Hash_setattr,
  Hash_delattr,
  Hash_firstkey,
  Hash_nextkey,
};

static DohObjInfo HashType = {
    "Hash",          /* objname */
    sizeof(Hash),    /* size */
    DelHash,         /* sm_del */
    CopyHash,        /* sm_copy */
    Hash_clear,      /* sm_clear */
    Hash_str,        /* sm_str */
    0,               /* doh_data */
    0,               /* doh_dump */
    Hash_len,        /* sm_len */
    0,               /* sm_hash    */
    0,               /* doh_cmp */
    &HashMappingMethods, /* doh_mapping */
    0,                /* doh_sequence */
    0,
    0,
    0,
    0,
    0,
};

DohObjInfo *Hash_type() {
  return &HashType;
}

int Hash_check(DOH *so) {
    Hash *h = (Hash *) so;
    if (!h) return 0;
    if (!DohCheck(so)) return 0;
    if (h->objinfo != &HashType) return 0;
    return 1;
}

/* -----------------------------------------------------------------------------
 * NewHash() -  Create a new hash table
 * ----------------------------------------------------------------------------- */

DOH *NewHash() {
    Hash *h;
    int   i;
    h = (Hash *) DohObjMalloc(sizeof(Hash));
    DohInit(h);
    h->hashsize = HASH_INIT_SIZE;
    h->hashtable = (HashNode **) DohMalloc(h->hashsize*sizeof(HashNode *));
    for (i = 0; i < h->hashsize; i++) {
	h->hashtable[i] = 0;
    }
    h->currentindex = -1;
    h->current = 0;
    h->nitems = 0;
    h->objinfo = &HashType;
    return (DOH *) h;
}

/* -----------------------------------------------------------------------------
 * DOH *CopyHash(DOH *ho) - Copy a hash table
 * ----------------------------------------------------------------------------- */

DOH *CopyHash(DOH *ho) {
    Hash *h, *nh;
    HashNode *n;
    int   i;
    DOH *key;

    h = (Hash *) ho;
    nh = (Hash *) DohObjMalloc(sizeof(Hash));
    DohInit(nh);

    nh->hashsize = h->hashsize;
    nh->hashtable = (HashNode **) DohMalloc(nh->hashsize*sizeof(HashNode *));
    for (i = 0; i < nh->hashsize; i++) {
	nh->hashtable[i] = 0;
    }
    nh->currentindex = -1;
    nh->current = 0;
    nh->nitems = 0;
    nh->objinfo = h->objinfo;

    for (i = 0; i < h->hashsize; i++) {
	if (n = h->hashtable[i]) {
	    while (n) {
		Hash_setattr(nh, n->key, n->object);
		n = n->next;
	    }
	}
    }
    return (DOH *) nh;
}

/* -----------------------------------------------------------------------------
 * DelHash() - Delete a hash table
 * ----------------------------------------------------------------------------- */

void DelHash(DOH *ho)
{
    Hash *h;
    HashNode *n,*next;
    int i;

    h = (Hash *) ho;
    for (i = 0; i < h->hashsize; i++) {
	if (n = h->hashtable[i]) {
	    while (n) {
		next = n->next;
		DelNode(n);
		n = next;
	    }
	}
    }
    DohFree(h->hashtable);
    DohObjFree(h);
}

/* -----------------------------------------------------------------------------
 * Hash_clear(DOH *ho) - Clear all entries in a hash table
 * ----------------------------------------------------------------------------- */

void Hash_clear(DOH *ho)
{
    Hash *h;
    HashNode *n,*next;
    int i;

    h = (Hash *) ho;
    for (i = 0; i < h->hashsize; i++) {
	if (n = h->hashtable[i]) {
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

/* ----------------------------------------------------------------------------- 
 * static resize(Hash *h) - Resizes the hash table
 * ----------------------------------------------------------------------------- */

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

    /* Walk down the old set of nodes */

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
 * int Hash_setattr(DOH *h, DOH *k, DOH *obj) - Adds an object to a hash
 * ----------------------------------------------------------------------------- */

int  
Hash_setattr(DOH *ho, DOH *k, DOH *obj) {
    int hv;
    HashNode *n, *prev;
    Hash *h;

    h = (Hash *) ho;
    hv = (Hashval(k)) % h->hashsize;
    n = h->hashtable[hv];
    prev = 0;
    while (n) {
      if (Cmp(n->key,k) == 0) {
	HashNode *nn;
	if (prev) {
	  prev->next = n->next;
	  h->hashtable[hv] = n->next;
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
 * DOH *Hash_getattr(DOH *ho, DOH *k) - Get an item from the hash table
 * ----------------------------------------------------------------------------- */

DOH *
Hash_getattr(DOH *ho, DOH *k) {
    int hv;
    HashNode *n;
    Hash *h;

    h = (Hash *) ho;
    hv = Hashval(k) % h->hashsize;
    n = h->hashtable[hv];
    while (n) {
	if (Cmp(n->key, k) == 0) return n->object;
	n = n->next;
    }
    return 0;
}

/* -----------------------------------------------------------------------------
 * void Hash_delattr(DOH *ho, DOH *k) - Delete an element from the table
 * ----------------------------------------------------------------------------- */

int
Hash_delattr(DOH *ho, DOH *k)
{
    HashNode *n, *prev;
    int hv;
    Hash *h;

    h = (Hash *) ho;
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

/* -----------------------------------------------------------------------------
 * Iterators
 * ----------------------------------------------------------------------------- */

static HashNode *hash_first(DOH *ho) {
    Hash *h = (Hash *) ho;
    h->currentindex = 0;
    h->current = 0;
    while (!h->hashtable[h->currentindex] && (h->currentindex < h->hashsize))
	h->currentindex++;
    if (h->currentindex >= h->hashsize) return 0;
    h->current = h->hashtable[h->currentindex];
    return h->current;
}

static HashNode *hash_next(DOH *ho) {
    Hash *h = (Hash *) ho;
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
    
DOH *
Hash_first(DOH *ho) {
    HashNode *hn = hash_first(ho);
    if (hn) return hn->object;
    return 0;
}

DOH *
Hash_next(DOH *ho)
{
    HashNode *hn = hash_next(ho);
    if (hn) return hn->object;
    return 0;
}

DOH *
Hash_firstkey(DOH *ho)
{
    HashNode *hn = hash_first(ho);
    if (hn) return hn->key;
    return 0;
}

DOH *
Hash_nextkey(DOH *ho)
{
    HashNode *hn = hash_next(ho);
    if (hn) return hn->key;
    return 0;
}

/* -----------------------------------------------------------------------------
 * String *Hash_str(DOH *ho) - Create a string representation of a hash
 * ----------------------------------------------------------------------------- */
DOH *
Hash_str(DOH *ho) {
    int i;
    HashNode *n;
    DOH *s;
    Hash *h;

    h = (Hash *) ho;
    s = NewString("");
    Printf(s,"Hash {\n");
    for (i = 0; i < h->hashsize; i++) {
	n = h->hashtable[i];
	while (n) {
	    Printf(s,"   '%s' : %s, \n", n->key, n->object);
	    n = n->next;
	}
    }
    Printf(s,"}\n");
#ifdef old
    s = NewString("Hash");
    Printf(s,"(%x) {",h);
    for (i = 0; i < h->hashsize; i++) {
	n = h->hashtable[i];
	while (n) {
	    Printf(s,"'%o',", n->key);
	    n = n->next;
	}
    }
    Printf(s,"}");
#endif
    return s;
}
      
/* -----------------------------------------------------------------------------
 * Hash_len(DOH *)
 * ----------------------------------------------------------------------------- */

int Hash_len(DOH *ho) {
  Hash *h = (Hash *) ho;
  return h->nitems;
}

/* -----------------------------------------------------------------------------
 * Hash_keys(DOH *)
 *
 * Return a list of keys
 * ----------------------------------------------------------------------------- */

DOH *Hash_keys(DOH *so) {
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

      
  
