/****************************************************************************
 * DOH
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which DOH
 * can be used and distributed.
 ****************************************************************************/

static char cvsroot[] = "$Header:";

/*******************************************************************************
 * File : list.c
 *
 * General purpose structure for keeping a list of reference counted Swig objects.
 *******************************************************************************/

#include "dohint.h"

typedef struct List {
    DOHXCOMMON;
    int          maxitems;        /* Max size  */
    int          nitems;          /* Num items */
    int          iter;            /* Iterator  */
    DOH        **items;
} List;

int List_check(DOH *);

/* Internal function.   Doubles amount of memory in a list */
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
 * DOH *CopyList(DOH *l)   - Copy a list
 * ----------------------------------------------------------------------------- */

static DOH *
CopyList(DOH *lo) {
    List *l,*nl;
    int i;
    l = (List *) lo;
    nl = (List *) DohObjMalloc(sizeof(List));
    DohXInit(nl);
    nl->objinfo = l->objinfo;
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
 * void DelList(DOH *l) - Delete a list
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
 * void List_clear(DOH *l) - Clear all elements in the list
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
 * void List_scope(DOH *lo, int s)
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
 * void List_insert(DOH *lo, int pos, DOH *item) - Insert an element
 * ----------------------------------------------------------------------------- */

static int 
List_insert(DOH *lo, int pos, DOH *item)
{
    List *l;
    DohBase *b;
    int i;

    if (!item) return -1;
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
    Setscope(b,l->scope);
    l->nitems++;
    return 0;
}

/* -----------------------------------------------------------------------------
 * void List_remove(DOH *lo, int pos) - Remove an element
 * ----------------------------------------------------------------------------- */
    
static int
List_remove(DOH *lo, int pos)
{
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
 * int List_len(DOH *l) - List length
 * ----------------------------------------------------------------------------- */

static int 
List_len(DOH *lo) 
{
    return ((List *) lo)->nitems;
}

/* -----------------------------------------------------------------------------
 * DOH *List_get(DOH *lo, int n) - Get an item
 * ----------------------------------------------------------------------------- */

static DOH *
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

static int
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
    Setscope(val,l->scope);
    return 0;
}

/* -----------------------------------------------------------------------------
 * Iterators 
 * ----------------------------------------------------------------------------- */

static DOH *
List_first(DOH *lo)
{
    List *l;
    l = (List *) lo;
    l->iter = 0;
    if (l->iter >= l->nitems) return 0;
    return l->items[l->iter];
}

static DOH *
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

static DOH *
List_str(DOH *lo) 
{
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

/* -----------------------------------------------------------------------------
 * void List_sort(DOH *DOH)
 *
 * Sorts a list 
 * ----------------------------------------------------------------------------- */

static int  objcmp(const void *s1, const void *s2) {
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

#define MAXLISTITEMS 8

static DohSequenceMethods ListSeqMethods = {
  List_get,
  List_set,
  List_remove,
  List_insert,
  List_first,
  List_next,
};

static DohPositionalMethods ListPositionalMethods = {
  XBase_setfile,
  XBase_getfile,
  XBase_setline,
  XBase_getline
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
    0,               /* doh_load */
    List_len,        /* doh_len */
    0,               /* doh_hash    */
    0,               /* doh_cmp */
    0,               /* doh_mapping */
    &ListSeqMethods, /* doh_sequence */
    0,               /* doh_file */
    0,               /* doh_string */
    0,               /* doh_callable */
    &ListPositionalMethods, /* doh_position */         
};

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
    l = (List *) DohObjMalloc(sizeof(List));
    DohXInit(l);
    l->objinfo = &ListType;
    l->nitems = 0;
    l->maxitems = MAXLISTITEMS;
    l->items = (void **) DohMalloc(l->maxitems*sizeof(void *));
    for (i = 0; i < MAXLISTITEMS; i++) {
	l->items[i] = 0;
    }
    l->iter = 0;
    return (DOH *) l;
}
