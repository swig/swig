/* ----------------------------------------------------------------------------- 
 * void.c
 *
 *     Implements a "void" object that is really just a DOH container around
 *     an arbitrary C object represented as a void *.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "dohint.h"

typedef struct {
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
  VoidObj *v = (VoidObj *) ObjData(vo);
  if (v->del)
    (*v->del)(v->ptr);
  DohFree(v);
}

/* -----------------------------------------------------------------------------
 * Void_copy()
 *
 * Copies a void object.  This is only a shallow copy. The object destruction
 * function is not copied in order to avoid potential double-free problems.
 * ----------------------------------------------------------------------------- */

static DOH *
Void_copy(DOH *vo) {
  VoidObj *v = (VoidObj *) ObjData(vo);
  return NewVoid(v->ptr,0);
}

/* -----------------------------------------------------------------------------
 * Void_data()
 *
 * Returns the void * stored in the object.
 * ----------------------------------------------------------------------------- */

static void *
Void_data(DOH *vo) {
  VoidObj *v = (VoidObj *) ObjData(vo);
  return v->ptr;
}

static DohObjInfo DohVoidType = {
  "VoidObj",        /* objname */
  Void_delete,      /* doh_del */
  Void_copy,        /* doh_copy */
  0,                /* doh_clear */
  0,                /* doh_str */
  Void_data,        /* doh_data */
  0,                /* doh_dump */
  0,                /* doh_len */
  0,                /* doh_hash    */
  0,                /* doh_cmp */
  0,                /* doh_setfile */
  0,                /* doh_getfile */
  0,                /* doh_setline */
  0,                /* doh_getline */
  0,                /* doh_mapping */
  0,                /* doh_sequence */
  0,                /* doh_file  */
  0,                /* doh_string */
  0,                /* doh_reserved */
  0,                /* clientdata */
};

/* -----------------------------------------------------------------------------
 * NewVoid()
 *
 * Creates a new Void object given a void * and an optional destructor function.
 * ----------------------------------------------------------------------------- */

DOH *
NewVoid(void *obj, void (*del)(void *)) {
  static int init = 0;
  VoidObj *v;
  if (!init) {
    DohRegisterType(DOHTYPE_VOID, &DohVoidType);
    init = 1;
  }
  v = (VoidObj *) DohMalloc(sizeof(VoidObj));
  v->ptr = obj;
  v->del = del;
  return DohObjMalloc(DOHTYPE_VOID,v);
}
