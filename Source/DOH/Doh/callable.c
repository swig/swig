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

static char cvsroot[] = "$Header$";

/* -----------------------------------------------------------------------------
 * callable.c
 *
 * Implements a callable function-like object.
 * ----------------------------------------------------------------------------- */

#include "dohint.h"

typedef struct {
    DOHCOMMON;
    DOH   *(*func)(DOH *, DOH *);
} CallableObj;

static void
Callable_delete(DOH *co) {
  DohObjFree(co);
}

static DOH *
Callable_copy(DOH *co) {
  CallableObj *c = (CallableObj *) co;
  return NewCallable(c->func);
}

static DOH *
Callable_call(DOH *co, DOH *args) {
  CallableObj *c = (CallableObj *) co;
  return (*c->func)(c,args);
}

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
  0,                    /* doh_load */
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

DOH *
NewCallable(DOH *(*func)(DOH *, DOH *)) {
  CallableObj *c;
  c = (CallableObj *) DohObjMalloc(sizeof(CallableObj));
  c->objinfo = &DohCallableType;
  c->func = func;
  return (DOH *) c;
}
