/* ----------------------------------------------------------------------------- 
 * void.c
 *
 *     Implements a "void" object that is really just a DOH container around
 *     an arbitrary C/C++ object represented as a void *.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "dohint.h"

typedef struct {
    DOHCOMMON;
    void   *ptr; 
    void   (*del)(void *);
} VoidObj;

/* -----------------------------------------------------------------------------
 * Void_delete()
 *
 * Delete a void object. Invokes the destructor supplied at the time of creation.
 * ----------------------------------------------------------------------------- */

static void
Void_delete(DOH *vo) {
  VoidObj *v = (VoidObj *) vo;
  if (v->del) {
    (*v->del)(v->ptr);
  }
  v->del = 0;
  DohObjFree(v);
}

/* -----------------------------------------------------------------------------
 * Void_copy()
 *
 * Copies a void object.  This is only a shallow copy. The object destruction
 * function is not copied in order to avoid potential double-free problems.
 * ----------------------------------------------------------------------------- */

static DOH *
Void_copy(DOH *vo) {
  VoidObj *v = (VoidObj *) vo;
  return NewVoid(v->ptr,0);
}

/* -----------------------------------------------------------------------------
 * Void_data()
 *
 * Returns the void * stored in the object.
 * ----------------------------------------------------------------------------- */

static void *
Void_data(DOH *vo) {
  VoidObj *v = (VoidObj *) vo;
  return v->ptr;
}

static DohObjInfo DohVoidType = {
  "VoidObj",        /* objname */
  sizeof(VoidObj),  /* objsize */
  Void_delete,      /* doh_del */
  Void_copy,        /* doh_copy */
  0,                /* doh_clear */
  0,                /* doh_str */
  Void_data,        /* doh_data */
  0,                /* doh_dump */
  0,                /* doh_load */
  0,                /* doh_len */
  0,                /* doh_hash    */
  0,                /* doh_cmp */
  0,                /* doh_mapping */
  0,                /* doh_sequence */
  0,                /* doh_file  */
  0,                /* doh_string */
  0,                /* doh_callable */
  0,                /* doh_position */
  0,                /* reserved5 */
  0,                /* reserved6 */
  0,                /* user1 */
  0,                /* user2 */
  0,                /* user3 */
  0,                /* user4 */
};


/* -----------------------------------------------------------------------------
 * NewVoid()
 *
 * Creates a new Void object given a void * and a pointer to an optional 
 * destruction function.
 * ----------------------------------------------------------------------------- */

DOH *
NewVoid(void *obj, void (*del)(void *)) {
  VoidObj *v;
  v = (VoidObj *) DohObjMalloc(sizeof(VoidObj));
  v->objinfo = &DohVoidType;
  v->ptr = obj;
  v->del = del;
  return (DOH *) v;
}
