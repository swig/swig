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
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 ****************************************************************************/

#include "doh.h"

#ifndef DOH_POOL_SIZE
#define DOH_POOL_SIZE         65536
#endif

#ifndef DOH_MAX_FRAG
#define DOH_MAX_FRAG          1024
#endif

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

/* ----------------------------------------------------------------------
 * Pool *CreatePool(int size)
 * 
 * Create a new pool
 * ---------------------------------------------------------------------- */

Pool *CreatePool(int size)
{
  Pool *p = 0;
  char *c;
  c = (char *) malloc(size);
  if (!c) return 0;

  p = (Pool *) malloc(sizeof(Pool));
  p->ptr = c;
  p->len = size;
  p->current = 0;
  p->next = 0;
  printf("Created pool : %x, %d\n", p->ptr, size);
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
  for (i = 0; i < 1024; i++) {
    FreeFragments[i] = 0;
  }
  Pools = CreatePool(DOH_POOL_SIZE);       /* Create initial pool */
  pools_initialized = 1;
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
 * int DohFreeCheck(DOH *ptr)
 * 
 * Check if ptr is an object that has been deleted.
 * ---------------------------------------------------------------------- */

int DohFreeCheck(DOH *ptr) {
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
 * void *DohMalloc(int size)
 *
 * Allocate an object
 * ---------------------------------------------------------------------- */

void *DohMalloc(int size) {
  Pool *p;
  Fragment *f;
  void *ptr;

  if (size > DOH_MAX_FRAG) return 0;
  if (!pools_initialized) InitPools();

  p = Pools;
  f = FreeFragments[size];
  if (f) {
    ptr = (void *) f->ptr;
    FreeFragments[size] = f->next;
    free(f);
    return ptr;
  }

  /* No free fragments.  See if the pool is large enough */
  
  if (size < (p->len - p->current)) {
    ptr = (void *) (p->ptr + p->current);
    p->current = (p->current + size + 7) & ~0x3;
    return ptr;
  }

  /* Pool is not large enough. Create a new pool */  
  
  if (p->len - p->current > 0) {
    f = (Fragment *) malloc(sizeof(Fragment));
    f->ptr = (p->ptr + p->current);
    f->len = (p->len - p->current);
    f->next = FreeFragments[f->len];
    FreeFragments[f->len] = f;
  }
  p = CreatePool(DOH_POOL_SIZE);
  p->next = Pools;
  Pools = p;
  return DohMalloc(size);
}

/* ----------------------------------------------------------------------
 * void DohFree(DOH *ptr)
 *
 * Free a DOH object.  Important! It must be a properly allocated
 * DOH object. Not something else.
 * ---------------------------------------------------------------------- */

void DohFree(DOH *ptr) {
  DohBase  *b;
  Fragment *f;
  if (!DohCheck(ptr)) {
    return;                  /* Oh well.  Guess we're leaky */
  }
  b = (DohBase *) ptr;
  if (!b->objinfo) return;   /* Improperly initialized object. leak some more */
  f = (Fragment *) malloc(sizeof(Fragment));
  f->ptr = (char *) ptr;
  f->len = b->objinfo->objsize; 
  f->next = FreeFragments[f->len];
  FreeFragments[f->len] = f;
}

  
  
