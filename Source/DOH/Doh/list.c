/* ----------------------------------------------------------------------------- 
 * list.c
 *
 *     Implements a simple list object.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "dohint.h"

typedef struct List {
    DOHXCOMMON;
    int          maxitems;        /* Max size  */
    int          nitems;          /* Num items */
    int          iter;            /* Iterator  */
    DOH        **items;
} List;

/* Doubles amount of memory in a list */
static 
void more(List *l) {
    int    i;
    void   **newitems;
  
    newitems = (void **) DohMalloc(l->maxitems*2*sizeof(void *));
    for (i = 0; i < l->maxitems; i++) {
	newitems[i] = l->items[i];
    }
    for (i = l->maxitems; i < 2*l->maxitems; i++) {
	newitems[i] = (void *) 0;
    }
    l->maxitems *= 2;
    DohFree(l->items);
    l->items = newitems;
}

/* -----------------------------------------------------------------------------
 * CopyList()
 *
 * Make a shallow copy of a list.
 * ----------------------------------------------------------------------------- */

static DOH *
CopyList(DOH *lo) {
    List *l,*nl;
    int i;
    l = (List *) lo;
    nl = (List *) DohObjMalloc(sizeof(List));
    nl->objinfo = l->objinfo;
    DohXInit(nl);
    nl->nitems = l->nitems;
    nl->maxitems = l->maxitems;
    nl->items = (void **) DohMalloc(l->maxitems*sizeof(void *));
    nl->iter = 0;
    for (i = 0; i < l->maxitems; i++) {
	nl->items[i] = l->items[i];
	if (nl->items[i]) {
	    Incref(nl->items[i]);
	}
    }
    nl->file = l->file;
    if (nl->file) Incref(nl->file);
    nl->line = l->line;
    return (DOH *) nl;
}

/* -----------------------------------------------------------------------------
 * DelList()
 *
 * Delete a list.
 * ----------------------------------------------------------------------------- */

static void
DelList(DOH *lo) {
    List *l;
    int i;
    l = (List *) lo;
    assert(l->refcount <= 0);
    for (i = 0; i < l->nitems; i++) {
	Delete(l->items[i]);
    }
    DohFree(l->items);
    l->items = 0;
    Delete(l->file);
    DohObjFree(l);
}

/* -----------------------------------------------------------------------------
 * List_clear()
 *
 * Remove all of the list entries, but keep the list object intact.
 * ----------------------------------------------------------------------------- */

static void
List_clear(DOH *lo) {
    List *l;
    int i;
    l = (List *) lo;
    for (i = 0; i < l->nitems; i++) {
	Delete(l->items[i]);
	l->items[i] = 0;
    }
    l->nitems = 0;
}

/* -----------------------------------------------------------------------------
 * List_scope()
 *
 * Change the scope setting of the list.
 * ----------------------------------------------------------------------------- */

static void
List_scope(DOH *lo, int s) {
  List *l;
  int i;
  l = (List *) lo;
  if (l->flags & DOH_FLAG_SETSCOPE) return;
  l->flags = l->flags | DOH_FLAG_SETSCOPE;
  if (s < l->scope) l->scope = (unsigned char) s;
  for (i = 0; i < l->nitems; i++) {
    Setscope(l->items[i],s);
  }
  l->flags = l->flags & ~DOH_FLAG_SETSCOPE;
}

/* -----------------------------------------------------------------------------
 * List_insert()
 *
 * Insert an item into the list. If the item is not a DOH object, it is assumed
 * to be a 'char *' and is used to construct an equivalent string object.
 * ----------------------------------------------------------------------------- */

static int 
List_insert(DOH *lo, int pos, DOH *item) {
  List *l;
  DohBase *b;
  int i, no = 0;
  
  if (!item) return -1;
  l = (List *) lo;

  if (!DohCheck(item)) {
    DohTrace(DOH_CONVERSION,"Unknown object %x being converted to a string in List_insert.\n", item);
    item = NewString(item);
    no = 1;
  }
  b = (DohBase *) item;  
  if (pos == DOH_END) pos = l->nitems;
  if (pos < 0) pos = 0;
  if (pos > l->nitems) pos = l->nitems;
  if (l->nitems == l->maxitems) more(l);
  for (i = l->nitems; i > pos; i--) {
    l->items[i] = l->items[i-1];
  }
  l->items[pos] = item;
  b->refcount++;
  Setscope(b,l->scope);
  l->nitems++;
  if (no) Delete(item);
  return 0;
}

/* -----------------------------------------------------------------------------
 * List_remove()
 *
 * Remove an item from a list.
 * ----------------------------------------------------------------------------- */
    
static int
List_remove(DOH *lo, int pos) {
    List *l;
    DOH *item;
    int   i;

    l = (List *) lo;
    if (pos == DOH_END) pos = l->nitems-1;
    if (pos == DOH_BEGIN) pos = 0;
    if ((pos < 0) || (pos >= l->nitems)) return -1;
    item = l->items[pos];
    for (i = pos; i < l->nitems-1; i++) {
	l->items[i] = l->items[i+1];
    }
    l->nitems--;
    Delete(item);
    return 0;
}

/* -----------------------------------------------------------------------------
 * List_len()
 *
 * Return the number of elements in the list
 * ----------------------------------------------------------------------------- */

static int 
List_len(DOH *lo) {
    return ((List *) lo)->nitems;
}

/* -----------------------------------------------------------------------------
 * List_get()
 *
 * Get the nth item from the list.
 * ----------------------------------------------------------------------------- */

static DOH *
List_get(DOH *lo, int n) {
    List *l;
    l = (List *) lo;
    if (n == DOH_END) n = l->nitems-1;
    if (n == DOH_BEGIN) n = 0;
    if ((n < 0) || (n >= l->nitems)) {
	printf("List_get : Invalid list index %d\n", n);
    }
    return l->items[n];
}

/* -----------------------------------------------------------------------------
 * List_set()
 *
 * Set the nth item in the list replacing any previous item. 
 * ----------------------------------------------------------------------------- */

static int
List_set(DOH *lo, int n, DOH *val) {
    List *l;
    int no = 0;
    l = (List *) lo;
    if ((n < 0) || (n >= l->nitems)) {
	printf("List_set : Invalid list index %d\n", n);
	return -1;
    }
    if (!DohCheck(val)) {
      DohTrace(DOH_CONVERSION,"Unknown object %x being converted to a string in List_setitem.\n", val);
      val = NewString(val);
      no = 1;
    }
    Delete(l->items[n]);
    l->items[n] = val;
    Incref(val);
    Setscope(val,l->scope);
    Delete(val);
    return 0;
}

/* -----------------------------------------------------------------------------
 * List_first()
 *
 * Return the first item in the list.
 * ----------------------------------------------------------------------------- */

static DOH *
List_first(DOH *lo) {
    List *l;
    l = (List *) lo;
    l->iter = 0;
    if (l->iter >= l->nitems) return 0;
    return l->items[l->iter];
}

/* -----------------------------------------------------------------------------
 * List_next()
 * 
 * Return the next item in the list.
 * ----------------------------------------------------------------------------- */

static DOH *
List_next(DOH *lo) {
    List *l;
    l = (List *) lo;
    l->iter++;
    if (l->iter >= l->nitems) return 0;
    return l->items[l->iter];
}

/* -----------------------------------------------------------------------------
 * List_str()
 *
 * Create a string representation of the list
 * ----------------------------------------------------------------------------- */
static DOH *
List_str(DOH *lo) {
    DOH *s;
    int i;

    List *l = (List *) lo;
    s = NewString("");
    if (l->flags & DOH_FLAG_PRINT) {
      Printf(s,"List(0x%x)",l);
      return s;
    }
    l->flags = l->flags | DOH_FLAG_PRINT;
    Printf(s,"List[ ");
    for (i = 0; i < l->nitems; i++) {
      Printf(s, "%s", l->items[i]);
      if ((i+1) < l->nitems)
	Printf(s,", ");
    }
    Printf(s," ]\n");
    l->flags = l->flags & ~DOH_FLAG_PRINT;
    return s;
}

/* -----------------------------------------------------------------------------
 * List_dump()
 *
 * Dump the items to an output stream.
 * ----------------------------------------------------------------------------- */

static int 
List_dump(DOH *lo, DOH *out) {
  int nsent = 0;
  int i,ret;
  List *l = (List *) lo;
  for (i = 0; i < l->nitems; i++) {
    ret = Dump(l->items[i],out);
    if (ret < 0) return -1;
    nsent += ret;
  }
  return nsent;
}

#define MAXLISTITEMS 8

static DohSequenceMethods ListSeqMethods = {
  List_get,
  List_set,
  List_remove,
  List_insert,
  List_first,
  List_next,
};

static DohObjInfo ListType = {
    "List",          /* objname */
    sizeof(List),    /* List size */
    DelList,         /* doh_del */
    CopyList,        /* doh_copy */
    List_clear,      /* doh_clear */
    List_scope,      /* doh_scope */
    List_str,        /* doh_str */
    0,               /* doh_data */
    List_dump,       /* doh_dump */
    List_len,        /* doh_len */
    0,               /* doh_hash    */
    0,               /* doh_cmp */
    0,               /* doh_mapping */
    &ListSeqMethods, /* doh_sequence */
    0,               /* doh_file */
    0,               /* doh_string */
    0,               /* doh_callable */
    0,               /* doh_position */         
};

/* -----------------------------------------------------------------------------
 * List_check()
 *
 * Return 1 if an object is a List object.
 * ----------------------------------------------------------------------------- */
int
List_check(DOH *lo) {
    List *l = (List *) lo;
    if (!l) return 0;
    if (!DohCheck(lo)) return 0;
    if (l->objinfo != &ListType) return 0;
    return 1;
}

/* -----------------------------------------------------------------------------
 * NewList()
 *
 * Create a new list.
 * ----------------------------------------------------------------------------- */

DOH *
NewList() {
    List *l;
    int   i;
    l = (List *) DohObjMalloc(sizeof(List));
    l->objinfo = &ListType;
    DohXInit(l);
    l->nitems = 0;
    l->maxitems = MAXLISTITEMS;
    l->items = (void **) DohMalloc(l->maxitems*sizeof(void *));
    for (i = 0; i < MAXLISTITEMS; i++) {
	l->items[i] = 0;
    }
    l->iter = 0;
    return (DOH *) l;
}

/* -----------------------------------------------------------------------------
 * List_sort()
 *
 * Sorts a list 
 * ----------------------------------------------------------------------------- */

static int  objcmp(const void *s1, const void *s2) {
  DOH **so1, **so2;
  so1 = (DOH **) s1;
  so2 = (DOH **) s2;
  return Cmp(*so1,*so2);
}

void
List_sort(DOH *so) {
  List *l;
  if (!List_check(so)) return;
  l = (List *) so;
  qsort(l->items,l->nitems,sizeof(DOH *), objcmp);
}
