/* ----------------------------------------------------------------------------- 
 * memory.c
 *
 *     This file implements all of DOH's memory management including allocation
 *     of objects and checking of objects.
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

static int   PoolSize = DOH_POOL_SIZE;
DOH    *DohNone = 0;    /* The DOH None object */

static DohBase *FreeFragments[DOH_MAX_FRAG];   /* Array of free memory fragments */

typedef struct pool {
  char          *ptr;            /* Start of pool */
  int            len;            /* Length of pool */
  int            current;        /* Current position for next allocation */
  struct  pool  *next;           /* Next pool */
} Pool;

static Pool    *Pools = 0;
static int      pools_initialized = 0;

/* ----------------------------------------------------------------------
 * CreatePool() - Create a new memory pool 
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
 * InitPools() - Initialize the memory allocator
 * ---------------------------------------------------------------------- */

static void 
InitPools() {
  int i;
  if (pools_initialized) return;
  for (i = 0; i < DOH_MAX_FRAG; i++) {
    FreeFragments[i] = 0;
  }
  Pools = CreatePool(PoolSize);       /* Create initial pool */
  pools_initialized = 1;
  DohNone = NewVoid(0,0);             /* Create the None object */
  DohIntern(DohNone);
}

/* ----------------------------------------------------------------------
 * DohCheck()
 *
 * Returns 1 if an arbitrary pointer is a DOH object.
 * ---------------------------------------------------------------------- */

/* Possible optimization:  Reorder pools to move last match to the beginning */
int 
DohCheck(const DOH *ptr) {
  Pool *p = Pools;
  char *cptr = (char *) ptr;
  while (p) {
    if ((cptr >= p->ptr) && (cptr < p->ptr+p->current)) {
      return 1;
    }
    p = p->next;
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
  DohBase *f;
  void *ptr = 0;

  if (size > DOH_MAX_FRAG) return 0;
  if (!pools_initialized) InitPools();

  /* adjust the size for double word alignment */
  size = (size + 7) & ~0x07;

  p = Pools;
  f = FreeFragments[size];
  if (f) {
    ptr = (void *) f;
    FreeFragments[size] = (DohBase *) f->file;
    DohInit(ptr);
    return ptr;
  }

  /* No free fragments.  See if the pool is large enough */
  if ((int) size < (p->len - p->current)) {
    ptr = (void *) (p->ptr + p->current);
    p->current = p->current + size;
    DohInit(ptr);
    return ptr;
  }
  PoolSize *= 2;
  p = CreatePool(PoolSize);
  p->next = Pools;
  Pools = p;
  return DohObjMalloc(size);
}

/* ----------------------------------------------------------------------
 * DohObjFree() - Free a DOH object
 * ---------------------------------------------------------------------- */

void 
DohObjFree(DOH *ptr) {
  DohBase  *b;
  int len;
  b = (DohBase *) ptr;
  if (b->flags & DOH_FLAG_INTERN) return;
  if (b->file) DohDelete(b->file);
  len = (b->objinfo->objsize + 7) & ~0x07; 
  b->file = (DOH *) FreeFragments[len];
  FreeFragments[len] = b;
  b->objinfo = 0;
  b->flags = b->flags | DOH_FLAG_DELETED;
}
