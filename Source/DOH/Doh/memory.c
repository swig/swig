/* ----------------------------------------------------------------------------- 
 * memory.c
 *
 *     This file implements all of DOH's memory management including allocation
 *     of objects, checking of objects, and garbage collection.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "dohint.h"

#ifndef DOH_POOL_SIZE
#define DOH_POOL_SIZE         128000
#endif

#ifndef DOH_MAX_FRAG
#define DOH_MAX_FRAG          1024
#endif

static int   _DohMemoryCurrent = 0;
static int   _DohMemoryHigh    = 0;
static int   _PoolSize = DOH_POOL_SIZE;
static int   num_fragments = 0;
static int   fragment_size = 0;
static int   obj_total_allocated = 0;
static int   obj_ntotal_allocated = 0;
static int   data_total_allocated = 0;

DOH    *DohNone = 0;    /* The DOH None object */

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

/* ----------------------------------------------------------------------
 * CreatePool()
 * 
 * Create a new memory pool
 * ---------------------------------------------------------------------- */

static Pool *
CreatePool(int size) {
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
 * InitPools()
 *
 * Initialize the memory allocator
 * ---------------------------------------------------------------------- */

static void 
InitPools() {
  int i;
  if (pools_initialized) return;
  for (i = 0; i < DOH_MAX_FRAG; i++) {
    FreeFragments[i] = 0;
  }
  Pools = CreatePool(_PoolSize);       /* Create initial pool */
  pools_initialized = 1;
  DohNone = NewVoid(0,0);
  DohIntern(DohNone);
}

/* ----------------------------------------------------------------------
 * DohCheck()
 *
 * Returns 1 if an arbitrary pointer is a DOH object.   This determination
 * is made according to the pointer value only.
 * ---------------------------------------------------------------------- */

int 
DohCheck(const DOH *ptr) {
  Pool *p = Pools;
  char *cptr = (char *) ptr;
  while (p) {
    if ((cptr >= p->ptr) && (cptr < p->ptr+p->current)) return 1;
    p = p->next;
  }
  return 0;
}

/* ----------------------------------------------------------------------
 * DohObjFreeCheck()
 * 
 * Checks to see if an object was already deleted.  Useful when tracking
 * down nasty double-free problems.
 * ---------------------------------------------------------------------- */

int 
DohObjFreeCheck(DOH *ptr) {
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
 * DohObjMalloc()
 *
 * Allocate memory for a new object.
 * ---------------------------------------------------------------------- */

void *
DohObjMalloc(size_t size) {
  Pool *p;
  Fragment *f;
  void *ptr = 0;
  int  garbage_collected = 0;

  if (size > DOH_MAX_FRAG) return 0;
  if (!pools_initialized) InitPools();

  /* adjust the size for double word alignment */
  size = (size + 7) & ~0x07;

  obj_total_allocated += size;
  obj_ntotal_allocated++;

 retry:
  p = Pools;
  f = FreeFragments[size];
  if (f) {
    ptr = (void *) f->ptr;
    FreeFragments[size] = f->next;
    num_fragments--;
    fragment_size -= f->len;
    DohFree(f);
    DohInit(ptr);
    return ptr;
  }

  /* No free fragments.  See if the pool is large enough */
  if ((int) size < (p->len - p->current)) {
    ptr = (void *) (p->ptr + p->current);
    /*     p->current = (p->current + size + 7) & ~0x3; */
    p->current = p->current + size;
    DohInit(ptr);
    return ptr;
  }

  /* Pool is not large enough. Create a new pool */  
  if (p->len - p->current > 0) {
    f = (Fragment *) DohMalloc(sizeof(Fragment));
    f->ptr = (p->ptr + p->current);
    f->len = (p->len - p->current);
    f->next = FreeFragments[f->len];
    p->current = p->len;
    FreeFragments[f->len] = f;
    num_fragments++;
    fragment_size += f->len;
  }
  p = CreatePool(_PoolSize);
  p->next = Pools;
  Pools = p;
  return DohObjMalloc(size);
}

/* ----------------------------------------------------------------------
 * DohObjFree()
 *
 * Frees a DOH object.  Doesn't do much with GC.
 * ---------------------------------------------------------------------- */

void 
DohObjFree(DOH *ptr) {
  Fragment *f;
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
  f = (Fragment *) DohMalloc(sizeof(Fragment));
  f->ptr = (char *) ptr;
  f->len = (b->objinfo->objsize + 7) & ~0x07; 
  f->next = FreeFragments[f->len];
  FreeFragments[f->len] = f;
  num_fragments++;
  fragment_size += f->len;
  obj_total_allocated -= f->len;
  obj_ntotal_allocated--;
  b->objinfo = 0;
}

/* -----------------------------------------------------------------------------
 * DohMalloc()
 *
 * Wrapper around malloc() function. Records memory usage.
 * ----------------------------------------------------------------------------- */

void *
DohMalloc(size_t nbytes) {
  data_total_allocated += nbytes;
  return (void *) malloc(nbytes);
}

/* -----------------------------------------------------------------------------
 * DohRealloc()
 *
 * Wrapper around realloc() function.
 * ----------------------------------------------------------------------------- */

void *
DohRealloc(void *ptr, size_t newsize) {
  return (void *) realloc(ptr,newsize);
}

/* -----------------------------------------------------------------------------
 * DohFree()
 *
 * Wrapper around free() function.
 * ----------------------------------------------------------------------------- */

void 
DohFree(void *ptr) {
  free(ptr);
}

/* -----------------------------------------------------------------------------
 * DohPoolSize()
 *
 * Change the size of the memory pools used by DOH
 * ----------------------------------------------------------------------------- */

int 
DohPoolSize(int poolsize) {
  int ps;
  ps = _PoolSize;
  if (poolsize > 0) {
    _PoolSize = poolsize;
  }
  return ps;
}

/* -----------------------------------------------------------------------------
 * DohMemoryInfo()
 *
 * Print memory information
 * ----------------------------------------------------------------------------- */

void
DohMemoryInfo() {

  fprintf(stderr,"DOH Memory Use\n");
  fprintf(stderr,"   Num free fragments :  %d (%d bytes)\n", num_fragments, fragment_size);
  fprintf(stderr,"   Obj total allocate :  %d (%d bytes)\n", obj_ntotal_allocated, obj_total_allocated);
  fprintf(stderr,"   Data allocate      :  %d\n", data_total_allocated);
}







