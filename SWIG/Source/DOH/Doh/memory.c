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
#define DOH_POOL_SIZE         16384
#endif

static int   PoolSize = DOH_POOL_SIZE;

DOH    *DohNone = 0;    /* The DOH None object */

typedef struct pool {
  DohBase       *ptr;            /* Start of pool */
  int            len;            /* Length of pool */
  int            blen;           /* Byte length of pool */
  int            current;        /* Current position for next allocation */
  struct  pool  *next;           /* Next pool */
} Pool;

DohBase  *FreeList = 0;          /* List of free objects */

static Pool    *Pools = 0;
static int      pools_initialized = 0;

/* ----------------------------------------------------------------------
 * CreatePool() - Create a new memory pool 
 * ---------------------------------------------------------------------- */

static void
CreatePool() {
  Pool *p = 0;
  p = (Pool *) DohMalloc(sizeof(Pool));
  assert(p);
  p->ptr = (DohBase *) DohMalloc(sizeof(DohBase)*PoolSize);
  assert(p->ptr);
  p->len = PoolSize;
  p->blen = PoolSize*sizeof(DohBase);
  p->current = 0;
  p->next = Pools;
  Pools = p;
}

/* ----------------------------------------------------------------------
 * InitPools() - Initialize the memory allocator
 * ---------------------------------------------------------------------- */

static void 
InitPools() {
  if (pools_initialized) return;
  CreatePool();                       /* Create initial pool */
  pools_initialized = 1;
  DohNone = NewVoid(0,0);             /* Create the None object */
  DohIntern(DohNone);
}

/* ----------------------------------------------------------------------
 * DohCheck()
 *
 * Returns 1 if an arbitrary pointer is a DOH object.
 * ---------------------------------------------------------------------- */

int 
DohCheck(const DOH *ptr) {
  Pool *p = Pools;
  register char *cptr = (char *) ptr;
  register char *pptr;
  while (p) {
    pptr = (char *) p->ptr;
    if ((cptr >= pptr) && (cptr < (pptr + p->blen))) return 1;
    /*
    pptr = (char *) p->ptr;
    if ((cptr >= pptr) && (cptr < (pptr+(p->current*sizeof(DohBase))))) return 1; */
    p = p->next;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohIntern()
 * ----------------------------------------------------------------------------- */

void
DohIntern(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  b->flag_intern = 1;
}

/* ----------------------------------------------------------------------
 * DohObjMalloc()
 *
 * Allocate memory for a new object.
 * ---------------------------------------------------------------------- */

DOH *
DohObjMalloc(int type, void *data) {
  DohBase *obj;
  if (!pools_initialized) InitPools();
  if (FreeList) {
    obj = FreeList;
    FreeList = (DohBase *) obj->data;
  } else {
    while (Pools->current == Pools->len) {
      PoolSize *= 2;
      CreatePool();
    }
    obj = Pools->ptr + Pools->current;
    Pools->current++;
  }
  obj->type = type;
  obj->data = data;
  obj->refcount = 1;
  obj->flag_intern = 0;
  obj->flag_marked = 0;
  return (DOH *) obj;
}

/* ----------------------------------------------------------------------
 * DohObjFree() - Free a DOH object
 * ---------------------------------------------------------------------- */

void 
DohObjFree(DOH *ptr) {
  DohBase  *b;
  b = (DohBase *) ptr;
  if (b->flag_intern) return;
  b->data = (void *) FreeList;
  b->type = 0;
  FreeList = b;
}
