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

/*******************************************************************************
 * $Header$
 *
 * File : list.c
 *
 * General purpose structure for keeping a list of reference counted Swig objects.
 *******************************************************************************/

#include "doh.h"

typedef struct List {
    DOHCOMMON;
    int          maxitems;        /* Max size  */
    int          nitems;          /* Num items */
    int          iter;            /* Iterator  */
    DOH        **items;
} List;

/* Forward references */

DOH      *CopyList(DOH *);
void     DelList(DOH *);
void     List_clear(DOH *);
DOH      *List_get(DOH *, int pos);
int      List_set(DOH *, int pos, DOH *obj);
int      List_insert(DOH *, int pos, DOH *item);
int      List_remove(DOH *, int pos);
int      List_len(DOH *);
DOH      *List_first(DOH *);
DOH      *List_next(DOH *);
DOH      *List_str(DOH *);
int       List_dump(DOH *, DOH *);

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
    DelList,         /* sm_del */
    CopyList,        /* sm_copy */
    List_clear,      /* sm_clear */
    List_str,        /* sm_str */
    0,               /* doh_data */
    List_dump,       /* doh_dump */
    List_len,        /* sm_len */
    0,               /* sm_hash    */
    0,               /* doh_cmp */
    0,               /* doh_mapping */
    &ListSeqMethods, /* doh_sequence */
    0,
    0,
    0,
    0,
    0,
};

DohObjInfo *List_type() {
  return &ListType;
}

/* Internal function.   Doubles amount of memory in a list */
static 
void more(List *l) {
    int    i;
    void   **newitems;
  
    newitems = (void **) malloc(l->maxitems*2*sizeof(void *));
    for (i = 0; i < l->maxitems; i++) {
	newitems[i] = l->items[i];
    }
    for (i = l->maxitems; i < 2*l->maxitems; i++) {
	newitems[i] = (void *) 0;
    }
    l->maxitems *= 2;
    free(l->items);
    l->items = newitems;
}

/* -----------------------------------------------------------------------------
 * List_check(DOH *lo) - Check to see if an object is a list
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
 * NewList() - Create a new list
 * ----------------------------------------------------------------------------- */

DOH *
NewList() {
    List *l;
    int   i;
    l = (List *) DohMalloc(sizeof(List));
    DohInit(l);
    l->objinfo = &ListType;
    l->nitems = 0;
    l->maxitems = MAXLISTITEMS;
    l->items = (void **) malloc(l->maxitems*sizeof(void *));
    for (i = 0; i < MAXLISTITEMS; i++) {
	l->items[i] = 0;
    }
    l->iter = 0;
    return (DOH *) l;
}

/* -----------------------------------------------------------------------------
 * DOH *CopyList(DOH *l)   - Copy a list
 * ----------------------------------------------------------------------------- */

DOH *
CopyList(DOH *lo) {
    List *l,*nl;
    int i;
    l = (List *) lo;
    nl = (List *) DohMalloc(sizeof(List));
    DohInit(nl);
    nl->objinfo = l->objinfo;
    nl->nitems = l->nitems;
    nl->maxitems = l->maxitems;
    nl->items = (void **) malloc(l->maxitems*sizeof(void *));
    nl->iter = 0;
    for (i = 0; i < l->maxitems; i++) {
	nl->items[i] = l->items[i];
	if (nl->items[i]) {
	    Incref(nl->items[i]);
	}
    }
    return (DOH *) nl;
}

/* -----------------------------------------------------------------------------
 * void DelList(DOH *l) - Delete a list
 * ----------------------------------------------------------------------------- */

void
DelList(DOH *lo) {
    List *l;
    int i;
    l = (List *) lo;
    assert(l->refcount <= 0);
    for (i = 0; i < l->nitems; i++) {
	Delete(l->items[i]);
    }
    free(l->items);
    DohFree(l);
}

/* -----------------------------------------------------------------------------
 * void List_clear(DOH *l) - Clear all elements in the list
 * ----------------------------------------------------------------------------- */

void
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
 * void List_insert(DOH *lo, int pos, DOH *item) - Insert an element
 * ----------------------------------------------------------------------------- */

int 
List_insert(DOH *lo, int pos, DOH *item)
{
    List *l;
    DohBase *b;
    int i;

    if (!item) return;
    b = (DohBase *) item;
    l = (List *) lo;

    if (pos == DOH_END) pos = l->nitems;
    if (pos < 0) pos = 0;
    if (pos > l->nitems) pos = l->nitems;
    if (l->nitems == l->maxitems) more(l);
    for (i = l->nitems; i > pos; i--) {
	l->items[i] = l->items[i-1];
    }
    l->items[pos] = item;
    b->refcount++;
    l->nitems++;
    return 0;
}

/* -----------------------------------------------------------------------------
 * void List_remove(DOH *lo, int pos) - Remove an element
 * ----------------------------------------------------------------------------- */
    
int
List_remove(DOH *lo, int pos)
{
    List *l;
    DOH *item;
    int   i;

    l = (List *) lo;
    if (pos == DOH_END) pos = l->nitems-1;
    if (pos == DOH_BEGIN) pos = 0;
    if ((pos < 0) || (pos >= l->nitems)) return;
    item = l->items[pos];
    for (i = pos; i < l->nitems-1; i++) {
	l->items[i] = l->items[i+1];
    }
    l->nitems--;
    Delete(item);
    return 0;
}

/* -----------------------------------------------------------------------------
 * int List_len(DOH *l) - List length
 * ----------------------------------------------------------------------------- */

int 
List_len(DOH *lo) 
{
    return ((List *) lo)->nitems;
}

/* -----------------------------------------------------------------------------
 * DOH *List_get(DOH *lo, int n) - Get an item
 * ----------------------------------------------------------------------------- */

DOH *
List_get(DOH *lo, int n) 
{
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
 * int List_set(DOH *lo, int n, DOH *val) - Set an item
 * ----------------------------------------------------------------------------- */

int
List_set(DOH *lo, int n, DOH *val) 
{
    List *l;

    l = (List *) lo;
    if ((n < 0) || (n >= l->nitems)) {
	printf("List_set : Invalid list index %d\n", n);
    }
    Delete(l->items[n]);
    l->items[n] = val;
    Incref(val);
    return 0;
}

/* -----------------------------------------------------------------------------
 * Iterators 
 * ----------------------------------------------------------------------------- */

DOH *
List_first(DOH *lo)
{
    List *l;
    l = (List *) lo;
    l->iter = 0;
    if (l->iter >= l->nitems) return 0;
    return l->items[l->iter];
}

DOH *
List_next(DOH *lo)
{
    List *l;
    l = (List *) lo;
    l->iter++;
    if (l->iter >= l->nitems) return 0;
    return l->items[l->iter];
}

/* -----------------------------------------------------------------------------
 * String *List_str() - Create a string representation
 * ----------------------------------------------------------------------------- */

DOH *
List_str(DOH *lo) 
{
    DOH *s;
    int i;

    List *l = (List *) lo;
    s = NewString("");
    Printf(s,"List [ ");
    for (i = 0; i < l->nitems; i++) {
      Printf(s, "     %s\n", l->items[i]);
      if ((i+1) < l->nitems)
	Printf(s,", ");
    }
    Printf(s," ]\n");
    return s;
}

int 
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

#ifdef SORT
/* -----------------------------------------------------------------------------
 * void List_sort(DOH *DOH)
 *
 * Sorts a list 
 * ----------------------------------------------------------------------------- */

int  objcmp(const void *s1, const void *s2) {
  DOH **so1, **so2;
  so1 = (DOH **) s1;
  so2 = (DOH **) s2;
  return Cmp(*so1,*so2);
}

void List_sort(DOH *so) {
  List *l;
  if (!List_check(so)) return;
  l = (List *) so;
  qsort(l->items,l->nitems,sizeof(DOH *), objcmp);
}
#endif




