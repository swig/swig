/* ----------------------------------------------------------------------------- 
 * callable.c
 *
 *     This file implements a simple callable object supporting a function call
 *     operation.
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
    DOH   *(*func)(DOH *, DOH *);
} CallableObj;

/* -----------------------------------------------------------------------------
 * Callable_delete()
 *
 * Destroy a callable object.
 * ----------------------------------------------------------------------------- */

static void
Callable_delete(DOH *co) {
  DohObjFree(co);
}

/* -----------------------------------------------------------------------------
 * Callable_copy()
 * 
 * Copy a callable object.
 * ----------------------------------------------------------------------------- */

static DOH *
Callable_copy(DOH *co) {
  CallableObj *c = (CallableObj *) co;
  return NewCallable(c->func);
}

/* ----------------------------------------------------------------------------- 
 * Callable_call()
 *
 * Call an object.  The object itself is passed as the first argument and remaining
 * arguments are passed as a second argument.
 * ----------------------------------------------------------------------------- */

static DOH *
Callable_call(DOH *co, DOH *args) {
  CallableObj *c = (CallableObj *) co;
  return (*c->func)(c,args);
}

/* Method tables */

static DohCallableMethods doh_callable_methods = {
  Callable_call
};

static DohObjInfo DohCallableType = {
  "CallableObj",        /* objname */
  sizeof(CallableObj),  /* objsize */
  Callable_delete,      /* doh_del */
  Callable_copy,        /* doh_copy */
  0,                    /* doh_clear */
  0,                    /* doh_scope */
  0,                    /* doh_str */
  0,                    /* doh_data */
  0,                    /* doh_dump */
  0,                    /* doh_len */
  0,                    /* doh_hash    */
  0,                    /* doh_cmp */
  0,                    /* doh_mapping */
  0,                    /* doh_sequence */
  0,                    /* doh_file  */
  0,                    /* doh_string */
  &doh_callable_methods,  /* doh_callable */
  0,                    /* doh_position */
  0,                    /* reserved5 */
  0,                    /* reserved6 */
  0,                    /* user1 */
  0,                    /* user2 */
  0,                    /* user3 */
  0,                    /* user4 */
};

/* -----------------------------------------------------------------------------
 * NewCallable()
 *
 * Create a new callable object.
 * ----------------------------------------------------------------------------- */

DOH *
NewCallable(DOH *(*func)(DOH *, DOH *)) {
  CallableObj *c;
  c = (CallableObj *) DohObjMalloc(sizeof(CallableObj));
  c->objinfo = &DohCallableType;
  c->func = func;
  return (DOH *) c;
}
