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

/* -----------------------------------------------------------------------------
 * void.c
 *
 * Void Object
 * ----------------------------------------------------------------------------- */

typedef struct {
    DOHCOMMON;
    void   *ptr; 
    void   (*del)(void *);
} VoidObj;

void  Void_delete(DOH *);
DOH  *Void_copy(DOH *);
void *Void_data(DOH *);

static DohObjInfo DohVoidType = {
  "VoidObj",        /* objname */
  sizeof(VoidObj),  /* objsize */
  Void_delete,      /* doh_del */
  Void_copy,        /* doh_copy */
  0,                /* doh_clear */
  0,                /* doh_str */
  Void_data,        /* doh_data */
  0,                /* doh_dump */
  0,                /* doh_len */
  0,                /* doh_hash    */
  0,                /* doh_cmp */
  0,                /* doh_mapping */
  0,                /* doh_sequence */
  0,                /* doh_file  */
  0,                /* reserved2 */
  0,                /* reserved3 */
  0,                /* reserved4 */
  0,                /* reserved5 */
  0,                /* reserved6 */
  0,                /* user1 */
  0,                /* user2 */
  0,                /* user3 */
  0,                /* user4 */
};


DOH *NewVoid(void *obj, void (*del)(void *)) {
  VoidObj *v;
  v = (VoidObj *) DohObjMalloc(sizeof(VoidObj));
  DohInit(v);
  v->objinfo = &DohVoidType;
  v->ptr = obj;
  v->del = del;
  return (DOH *) v;
}

void Void_delete(DOH *vo) {
  VoidObj *v = (VoidObj *) vo;
  if (v->del) {
    (*v->del)(v->ptr);
  }
  DohObjFree(v);
}

DOH *Void_copy(DOH *vo) {
  VoidObj *v = (VoidObj *) vo;
  return NewVoid(v->ptr,0);
}

void *Void_data(DOH *vo) {
  VoidObj *v = (VoidObj *) vo;
  return v->ptr;
}

