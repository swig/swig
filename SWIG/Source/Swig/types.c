/* ----------------------------------------------------------------------------- 
 * types.c
 *
 *     This file defines a generic type object implementation.  Types are
 *     defined recursively as described in the "dragon book", pg. 355.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"

/* External structure */
typedef struct SwigType {
  DOHXCOMMON;
  int            type;
  DOH           *value;
  struct SwigType *next;
  struct SwigType *prev;
} SwigType;

/* -----------------------------------------------------------------------------
 * SwigType_copy()
 *
 * Copy a datatype.
 * ----------------------------------------------------------------------------- */
DOH *
SwigType_copy(DOH *tobj) {
  SwigType *t = (SwigType *) tobj;
  SwigType *nt;

  nt = NewSwigType(t->type, Copy(t->value));
  nt->prev = 0;
  nt->next = (SwigType *) Copy(t->next);
  return (DOH *) nt;
}

/* -----------------------------------------------------------------------------
 * SwigType_delete()
 * 
 * Delete a datatype.
 * ----------------------------------------------------------------------------- */

void
SwigType_delete(DOH *tobj) {
  SwigType *t = (SwigType *) tobj;
  Delete(t->value);
  Delete(t->next);
  DohObjFree(t);
}

/* -----------------------------------------------------------------------------
 * SwigType_str()
 *
 * Create a string representation of this datatype.  This is language neutral
 * and is really ugly.
 * ----------------------------------------------------------------------------- */

DOH *
SwigType_str(DOH *tobj) {
  DOH *s, *s1;
  SwigType *t = (SwigType *) tobj;
  s = NewString("");
  switch(t->type) {
  case SWIG_TYPE_BYTE:
    Printf(s,"BYTE");
    break;
  case SWIG_TYPE_UBYTE:
    Printf(s,"UBYTE");
    break;
  case SWIG_TYPE_SHORT:
    Printf(s,"SHORT");
    break;
  case SWIG_TYPE_USHORT:
    Printf(s,"USHORT");
    break;
  case SWIG_TYPE_INT:
    Printf(s,"INT");
    break;
  case SWIG_TYPE_UINT:
    Printf(s,"UINT");
    break;
  case SWIG_TYPE_LONG:
    Printf(s,"LONG");
    break;
  case SWIG_TYPE_ULONG:
    Printf(s,"ULONG");
    break;
  case SWIG_TYPE_LONGLONG:
    Printf(s,"LONGLONG");
    break;
  case SWIG_TYPE_ULONGLONG:
    Printf(s,"ULONGLONG");
    break;
  case SWIG_TYPE_FLOAT:
    Printf(s,"FLOAT");
    break;
  case SWIG_TYPE_DOUBLE:
    Printf(s,"DOUBLE");
    break;
  case SWIG_TYPE_QUAD:
    Printf(s,"QUAD");
    break;
  case SWIG_TYPE_CHAR:
    Printf(s,"CHAR");
    break;
  case SWIG_TYPE_WCHAR:
    Printf(s,"WCHAR");
    break;
  case SWIG_TYPE_VOID:
    Printf(s,"VOID");
    break;
  case SWIG_TYPE_ENUM:
    Printf(s,"ENUM-%s", t->value);
    break;
  case SWIG_TYPE_VARARGS:
    Printf(s,"VARARGS");
    break;
  case SWIG_TYPE_TYPEDEF:
    Printf(s,"TYPEDEF-%s",t->value);
    break;
  case SWIG_TYPE_POINTER:
    Printf(s,"POINTER");
    break;
  case SWIG_TYPE_REFERENCE:
    Printf(s,"REFERENCE");
    break;
  case SWIG_TYPE_FUNCTION:
    Printf(s,"FUNCTION[%s]",t->value);
    break;
  case SWIG_TYPE_ARRAY:
    Printf(s,"ARRAY[%s]",t->value);
    break;
  case SWIG_TYPE_RECORD:
    Printf(s,"RECORD[%s]",t->value);
    break;
  case SWIG_TYPE_NAME:
    Printf(s,"NAME-%s",t->value);
    break;
  default:
    Printf(s,"UNKNOWN");
    break;
  }
  if (t->next) {
    s1 = SwigType_str(t->next);
    Printf(s,"(%s)",s1);
    Delete(s1);
  }
  return s;
}

/* -----------------------------------------------------------------------------
 * SwigType_len()
 *
 * Return the length of a type (the number of type constructors)
 * ----------------------------------------------------------------------------- */

int SwigType_len(DOH *tobj) {
  SwigType *t = (SwigType *) tobj;
  if (t->next) return (1 + SwigType_len(t->next));
  return 1;
}

/* -----------------------------------------------------------------------------
 * SwigType_getitem()
 *
 * Get the nth item from the type
 * ----------------------------------------------------------------------------- */

DOH *SwigType_getitem(DOH *tobj, int n) {
  SwigType *t = (SwigType *) tobj;

  if (n == 0) {
    return tobj;
  }
  if ((n < 0) && (t->prev)) return SwigType_getitem(t->prev,n+1);
  if ((n > 0) && (t->next)) return SwigType_getitem(t->next,n-1);
  return 0;
}

/* -----------------------------------------------------------------------------
 * SwigType_setitem()
 *
 * Change the nth item for this type
 * ----------------------------------------------------------------------------- */

int SwigType_setitem(DOH *tobj, int n, DOH *value) {
  SwigType *tv;
  SwigType *t = (SwigType *) tobj;
  if (!SwigType_check(value)) return -1;

  tv = (SwigType *) value;
  if (n == 0) {
    tv->prev = t->prev;
    {
      SwigType *tt = tv;
      while (tt->next) {
	tt = (SwigType *) tt->next;
      }
      tt->next = t->next;
      if (t->next) t->next->prev = tt;
    }
    if (t->prev) t->prev->next = tv;
    Incref(tv);
    Setscope(tv,t->scope);
    t->next = 0;
    t->prev = 0;
    Delete(t);
    return 0;
  }
  if ((n < 0) && (t->prev)) return SwigType_setitem(t->prev,n+1,value);
  if ((n > 0) && (t->next)) return SwigType_setitem(t->next,n-1,value);
  return -1;
}

/* -----------------------------------------------------------------------------
 * SwigType_delitem()
 *
 * Delete an item from the type constructor list
 * ----------------------------------------------------------------------------- */

int SwigType_delitem(DOH *tobj, int n) {
  SwigType *t = (SwigType *) tobj;
  
  if (n == 0) {
    if (t->prev) t->prev->next = t->next;
    if (t->next) t->next->prev = t->prev;
    t->next = 0;
    t->prev = 0;
    Delete(t);
    return 0;
  }
  if ((n < 0) && (t->prev)) return SwigType_delitem(t->prev,n+1);
  if ((n > 0) && (t->next)) return SwigType_delitem(t->next,n-1);
  return -1;
}

/* -----------------------------------------------------------------------------
 * SwigType_insert()
 *
 * Inserts a new constructor into the type.
 * ----------------------------------------------------------------------------- */

static int 
SwigType_insert(DOH *tobj, int pos, DOH *item) {
  SwigType *t = (SwigType *) tobj;
  SwigType *tv, *tt, *tt1, *tp;
  int i, l;
  
  if (!SwigType_check(item)) return -1;
  l = SwigType_len(t);
  if (pos == DOH_END) pos = l;
  if (pos < 0) pos = 0;
  if (pos > l) pos = l;
  tt = t;
  tp = t;
  for (i = 0; i < pos; i++) {
    tp = t;
    tt = t->next;
  }
  tv = (SwigType *) item;
  tv->prev = tp;
  if (tt)
    tv->next = tt;
  tt1 = tv;
  while (tt1->next) {
    tt1 = (SwigType *) tt1->next;
  }
  if (tt) {
    tt1->next = tt->next;
    if (tt->next) tt->next->prev = tt1;
    if (tt->prev) tt->prev->next = tv;
  } else {
    tp->next = tv;
  }
  Incref(tv);
  Setscope(t, t->scope);
  return 0;
}

/* -----------------------------------------------------------------------------
 * void SwigType_scope()
 *
 * Set the scope on this object.
 * ----------------------------------------------------------------------------- */

void SwigType_scope(DOH *tobj, int s) {
  SwigType *t = (SwigType *) tobj;
  t->scope = s;
  if (t->next) SwigType_scope(t->next,s);
}

static DohSequenceMethods SwigTypeSeqMethods = {
  SwigType_getitem,
  SwigType_setitem,
  SwigType_delitem,
  SwigType_insert,
  0,
  0,
};

static DohObjInfo SwigTypeType = {
    "SwigType",          /* objname */
    sizeof(SwigType),    /* List size */
    SwigType_delete,      /* doh_del */
    SwigType_copy,   /* doh_copy */
    0,               /* doh_clear */
    SwigType_scope,  /* doh_scope */
    SwigType_str,    /* doh_str */
    0,               /* doh_data */
    0,               /* doh_dump */
    0,               /* doh_load */
    SwigType_len,    /* doh_len */
    0,               /* doh_hash    */
    0,               /* doh_cmp */
    0,               /* doh_mapping */
    &SwigTypeSeqMethods, /* doh_sequence */
    0,               /* doh_file */
    0,               /* doh_string */
    0,               /* doh_callable */
    0,               /* doh_position */         
};

/* -----------------------------------------------------------------------------
 * SwigType_check()
 *
 * Return 1 if an object is a SwigType object.
 * ----------------------------------------------------------------------------- */
int
SwigType_check(DOH *tobj) {
    SwigType *t = (SwigType *) tobj;
    if (!t) return 0;
    if (!DohCheck(tobj)) return 0;
    if (t->objinfo != &SwigTypeType) return 0;
    return 1;
}

          
/* -----------------------------------------------------------------------------
 * NewSwigType()
 * 
 * Create a new datatype
 * ----------------------------------------------------------------------------- */

DOH *
NewSwigType(int code, DOH *value) {
  SwigType *t;
  t = (SwigType *) DohObjMalloc(sizeof(SwigType));
  t->objinfo = &SwigTypeType;
  DohXInit(t);
  t->type = code;
  t->value = 0;
  if (value) {
    if (!DohCheck(value)) t->value = NewString(value);
    else {
      t->value = value;
      Incref(value);
    }
  }
  t->next = 0;
  t->prev = 0;
}
