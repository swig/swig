/****************************************************************************
 * DOH (Dynamic Object Hack)
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

static char cvsroot[] = "$Header$";

#include "dohint.h"

#ifndef DOH_POOL_SIZE
#define DOH_POOL_SIZE         128000
#endif

#ifndef DOH_MAX_FRAG
#define DOH_MAX_FRAG          1024
#endif

#ifndef DOH_MAX_SCOPES 
#define DOH_MAX_SCOPES        256
#endif

static int   _DohMemoryCurrent = 0;
static int   _DohMemoryHigh    = 0;
static int   _PoolSize = DOH_POOL_SIZE;

DOH    *DohNone = 0;

/* -----------------------------------------------------------------------------
 * memory.c
 *
 * Doh memory manager.    Keeps pools of memory around for allocating objects.
 * Pools are used to determine if an object is really a Doh object or not. 
 * ----------------------------------------------------------------------------- */

typedef struct fragment {
  char             *ptr;        /* Pointer to fragment */
  int               len;        /* Length of fragment */
  struct fragment  *next;       /* Next fragment */
} Fragment;

static Fragment *FreeFragments[DOH_MAX_FRAG];

typedef struct pool {
  char          *ptr;           /* Start of pool */
  int            len;           /* Length of pool */
  int            current;       /* Current position for next allocation */
  struct  pool  *next;          /* Next pool */
} Pool;

static Pool    *Pools = 0;
static int      pools_initialized = 0;
static DohBase *scopes[DOH_MAX_SCOPES];
static int      nscopes = 0;


/* ----------------------------------------------------------------------
 * Pool *CreatePool(int size)
 * 
 * Create a new pool
 * ---------------------------------------------------------------------- */

Pool *CreatePool(int size)
{
  Pool *p = 0;
  char *c;
  c = (char *) DohMalloc(size);
  if (!c) return 0;

  p = (Pool *) DohMalloc(sizeof(Pool));
  p->ptr = c;
  p->len = size;
  p->current = 0;
  p->next = 0;
  return p;
}

/* ----------------------------------------------------------------------
 * void InitPools()
 *
 * Initialize the memory allocator
 * ---------------------------------------------------------------------- */

static void InitPools() {
  int i;
  if (pools_initialized) return;
  for (i = 0; i < DOH_MAX_FRAG; i++) {
    FreeFragments[i] = 0;
  }
  Pools = CreatePool(_PoolSize);       /* Create initial pool */
  pools_initialized = 1;
  for (i = 0; i < DOH_MAX_SCOPES; i++) {
    scopes[i] = 0;
  }
  DohNewScope();                       /* Initialize the scope system */
  DohNone = NewVoid(0,0);
  DohIntern(DohNone);
}

/* ----------------------------------------------------------------------
 * int DohCheck(DOH *ptr)
 *
 * Check if ptr is an object we created.
 * ---------------------------------------------------------------------- */

int DohCheck(DOH *ptr) {
  Pool *p = Pools;
  char *cptr = (char *) ptr;
  while (p) {
    if ((cptr >= p->ptr) && (cptr < p->ptr+p->current)) return 1;
    p = p->next;
  }
  return 0;
}

/* ----------------------------------------------------------------------
 * int DohObjFreeCheck(DOH *ptr)
 * 
 * Check if ptr is an object that has been deleted.
 * ---------------------------------------------------------------------- */

int DohObjFreeCheck(DOH *ptr) {
  int i;
  Fragment *f;
  char *cptr = (char *) ptr;
  for (i = 0; i < DOH_MAX_FRAG; i++) {
    f = FreeFragments[i];
    while (f) {
      if (f->ptr == cptr) return 1;
      f = f->next;
    }
  }
  return 0;
}

/* ----------------------------------------------------------------------
 * int DohNewScope()
 *
 * Create a new scope in which objects will be placed
 * ---------------------------------------------------------------------- */
int DohNewScope() 
{
  assert(nscopes < DOH_MAX_SCOPES);
  if (!pools_initialized) InitPools();
  scopes[nscopes] = 0;
  nscopes++;
  return nscopes - 1;
}

/* ----------------------------------------------------------------------
 * void DohDelScope(int s) - Delete scope s
 * ---------------------------------------------------------------------- */

void DohDelScope(int s)
{
  int ns;
  DohBase *b, *b1;
  ns = s;
  assert((s >= 0) && (s < nscopes));
  s = nscopes - 1;
  while (s >= ns) {
    b = scopes[s];
    b1 = 0;
    while (b) {
      if (s <= b->scope) {
	if (!(b->flags & DOH_FLAG_DELSCOPE)) {
	  Delete(b);
	  b->flags = b->flags | DOH_FLAG_DELSCOPE;
	}
      }
      b1 = b;
      b = (DohBase *) (b->nextptr);
    }
    if (ns > 0) {      /* Add objects to highest non-deleted scope */
      if (b1) {
	b1->nextptr = (DOH *) scopes[ns-1];
	scopes[ns-1] = (DohBase *) scopes[s];
      }
    }
    scopes[s] = 0;
    s--;
  }
  nscopes = ns;
}

/* ----------------------------------------------------------------------
 * void real_objfree(DOH *ptr) - Free a DOH object for real.
 * ---------------------------------------------------------------------- */
static void real_objfree(DOH *ptr) {
  DohBase  *b;
  Fragment *f;
  b = (DohBase *) ptr;

  if (!b->objinfo) {
    DohTrace(DOH_MEMORY,"DohObjFree. %x not properly defined.  No objinfo structure.\n", ptr);
    return;   /* Improperly initialized object. leak some more */
  }
  f = (Fragment *) DohMalloc(sizeof(Fragment));
  f->ptr = (char *) ptr;
  f->len = (b->objinfo->objsize + 7) & ~0x07; 
  f->next = FreeFragments[f->len];
  FreeFragments[f->len] = f;

}

/* ----------------------------------------------------------------------
 * void DohGarbageCollect()
 *
 * This walks through all of the scopes and does garbage collection.
 *
 *    1.   Objects with refcount <= 0 are released.
 *    2.   The scopes data structures are rebuilt and compacted.
 * ---------------------------------------------------------------------- */

void
DohGarbageCollect() {
  int s;
  DohBase *b, *b1;
  int ndeleted = 1;

  DohTrace(DOH_MEMORY,"Garbage collecting.\n");
  while (ndeleted) {
    ndeleted = 0;
    s = nscopes - 1;
    while (s >= 0) {
      b = scopes[s];
      b1 = 0;
      while (b) {
	if ((b->refcount <= 0)) {
	  if (b1) {
	    b1->nextptr = b->nextptr;
	  } else {
	    scopes[s] = b->nextptr;
	  }
	  if (!(b->flags & DOH_FLAG_INTERN)) {
	    assert(!(b->flags & DOH_FLAG_GC));
	    real_objfree(b);               /* Release the object */
	    b->flags = b->flags | DOH_FLAG_GC;
	  }
	  ndeleted++;
	} else {
	  b1 = b;
	}
	b = (DohBase *) b->nextptr;
      }
      s--;
    }
  }
  DohTrace(DOH_MEMORY,"Done garbage collecting.\n");
}

/* ----------------------------------------------------------------------
 * void *DohObjMalloc(size_t size)
 *
 * Allocate an object
 * ---------------------------------------------------------------------- */

void *DohObjMalloc(size_t size) {
  Pool *p;
  Fragment *f;
  void *ptr = 0;
  int  garbage_collected = 0;

  if (size > DOH_MAX_FRAG) return 0;
  if (!pools_initialized) InitPools();

  /* adjust the size for double word alignment */
  size = (size + 7) & ~0x07;
  
 retry:
  p = Pools;
  f = FreeFragments[size];
  if (f) {
    ptr = (void *) f->ptr;
    FreeFragments[size] = f->next;
    DohFree(f);
    DohInit(ptr);
    if (nscopes) {
      ((DohBase *) ptr)->scope = nscopes-1;
      ((DohBase *) ptr)->nextptr = scopes[nscopes-1];
      scopes[nscopes-1] = (DohBase *) ptr;
    }
    return ptr;
  }

  /* No free fragments.  See if the pool is large enough */
  if ((int) size < (p->len - p->current)) {
    ptr = (void *) (p->ptr + p->current);
    /*     p->current = (p->current + size + 7) & ~0x3; */
    p->current = p->current + size;
    DohInit(ptr);
    if (nscopes) {
      ((DohBase *) ptr)->scope = nscopes-1;
      ((DohBase *) ptr)->nextptr = scopes[nscopes-1];
      scopes[nscopes-1] = (DohBase *) ptr;
    }
    return ptr;
  }

  if (!garbage_collected) {
    garbage_collected = 1;
    DohGarbageCollect();
    goto retry;
  }

  /* Pool is not large enough. Create a new pool */  
  if (p->len - p->current > 0) {
    f = (Fragment *) DohMalloc(sizeof(Fragment));
    f->ptr = (p->ptr + p->current);
    f->len = (p->len - p->current);
    f->next = FreeFragments[f->len];
    p->current = p->len;
    FreeFragments[f->len] = f;
  }

  p = CreatePool(_PoolSize);
  p->next = Pools;
  Pools = p;
  return DohObjMalloc(size);
}

/* ----------------------------------------------------------------------
 * void DohObjFree(DOH *ptr)
 *
 * Free a DOH object.  This function doesn't do much of anything with GC.
 * ---------------------------------------------------------------------- */

void DohObjFree(DOH *ptr) {
  DohBase  *b;

  if (!DohCheck(ptr)) {
    DohTrace(DOH_MEMORY,"DohObjFree. %x not a DOH object!\n", ptr);
    return;                  /* Oh well.  Guess we're leaky */
  }
  b = (DohBase *) ptr;
  if (!b->objinfo) {
    DohTrace(DOH_MEMORY,"DohObjFree. %x not properly defined.  No objinfo structure.\n", ptr);
    return;   /* Improperly initialized object. leak some more */
  }
}

/* -----------------------------------------------------------------------------
 * void *DohMalloc(size_t nbytes)
 *
 * Wrapper around malloc() function. Records memory usage.
 * ----------------------------------------------------------------------------- */

void *DohMalloc(size_t nbytes) {
  char *ptr;
  ptr = (char *) malloc(nbytes+8);
  if (!ptr) return 0;
  _DohMemoryCurrent += (nbytes+8);
  if (_DohMemoryCurrent > _DohMemoryHigh) _DohMemoryHigh = _DohMemoryCurrent;
  *((int *) ptr) = nbytes;
  return (void *) (ptr+8);
}

/* -----------------------------------------------------------------------------
 * void *DohRealloc(void *ptr, size_t newsize)
 *
 * Wrapper around realloc() function.
 * ----------------------------------------------------------------------------- */

void *DohRealloc(void *ptr, size_t newsize) {
  char *cptr = (char *) ptr;
  char *nptr;
  int  size;

  size = *((int *) (cptr - 8));
  nptr = (char *) realloc(cptr-8,newsize+8);
  if (!nptr) return 0;
  *((int *) nptr) = newsize;
  _DohMemoryCurrent += (newsize - size);
  if (_DohMemoryCurrent > _DohMemoryHigh) _DohMemoryHigh = _DohMemoryCurrent;
  return (void *) (nptr+8);
}

/* -----------------------------------------------------------------------------
 * void DohFree(void *ptr)
 *
 * Wrapper around free() function.  Records memory usage.
 * ----------------------------------------------------------------------------- */

void DohFree(void *ptr) {
  char *cptr = (char *) ptr;
  int size;
  if (!ptr) return;
  size = *((int *) (cptr - 8));
  free(cptr-8);
  _DohMemoryCurrent = _DohMemoryCurrent - (size+8);
}

/* -----------------------------------------------------------------------------
 * int DohMemoryUse()
 *
 * Return bytes currently in use by Doh
 * ----------------------------------------------------------------------------- */

int DohMemoryUse() {
  return _DohMemoryCurrent;
}
  
int DohMemoryHigh() {
  return _DohMemoryHigh;
}

int DohPoolSize(int poolsize) {
  int ps;
  ps = _PoolSize;
  if (poolsize > 0) {
    _PoolSize = poolsize;
  }
  return ps;
}









