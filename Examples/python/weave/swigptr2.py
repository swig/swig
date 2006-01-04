# This code allows one to use SWIG wrapped objects from weave.  This
# code is specific to SWIG-1.3 and above where things are different.
# The code is basically all copied out from the SWIG wrapper code but
# it has been hand edited for brevity.
#
# Prabhu Ramachandran <prabhu@aero.iitm.ernet.in>

######################################################################
# This is for SWIG-1.3.x where x < 22.
# Essentially, SWIG_RUNTIME_VERSION was not yet used.
swigptr2_code_v0 = """

#include "Python.h"

/*************************************************************** -*- c -*-
 * python/precommon.swg
 *
 * Rename all exported symbols from common.swg, to avoid symbol
 * clashes if multiple interpreters are included
 *
 ************************************************************************/

#define SWIG_TypeCheck       SWIG_Python_TypeCheck
#define SWIG_TypeCast        SWIG_Python_TypeCast
#define SWIG_TypeName        SWIG_Python_TypeName
#define SWIG_TypeQuery       SWIG_Python_TypeQuery
#define SWIG_PackData        SWIG_Python_PackData 
#define SWIG_UnpackData      SWIG_Python_UnpackData 


/***********************************************************************
 * common.swg
 *
 *     This file contains generic SWIG runtime support for pointer
 *     type checking as well as a few commonly used macros to control
 *     external linkage.
 *
 * Author : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (c) 1999-2000, The University of Chicago
 * 
 * This file may be freely redistributed without license or fee provided
 * this copyright message remains intact.
 ************************************************************************/

#include <string.h>

#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#  if defined(_MSC_VER) || defined(__GNUC__)
#    if defined(STATIC_LINKED)
#      define SWIGEXPORT(a) a
#      define SWIGIMPORT(a) extern a
#    else
#      define SWIGEXPORT(a) __declspec(dllexport) a
#      define SWIGIMPORT(a) extern a
#    endif
#  else
#    if defined(__BORLANDC__)
#      define SWIGEXPORT(a) a _export
#      define SWIGIMPORT(a) a _export
#    else
#      define SWIGEXPORT(a) a
#      define SWIGIMPORT(a) a
#    endif
#  endif
#else
#  define SWIGEXPORT(a) a
#  define SWIGIMPORT(a) a
#endif

#ifdef SWIG_GLOBAL
#  define SWIGRUNTIME(a) SWIGEXPORT(a)
#else
#  define SWIGRUNTIME(a) static a
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void *(*swig_converter_func)(void *);
typedef struct swig_type_info *(*swig_dycast_func)(void **);

typedef struct swig_type_info {
  const char             *name;
  swig_converter_func     converter;
  const char             *str;
  void                   *clientdata;
  swig_dycast_func        dcast;
  struct swig_type_info  *next;
  struct swig_type_info  *prev;
} swig_type_info;

#ifdef SWIG_NOINCLUDE

SWIGIMPORT(swig_type_info *) SWIG_TypeCheck(char *c, swig_type_info *);
SWIGIMPORT(void *)           SWIG_TypeCast(swig_type_info *, void *);
SWIGIMPORT(const char *)     SWIG_TypeName(const swig_type_info *);
SWIGIMPORT(swig_type_info *) SWIG_TypeQuery(const char *);
SWIGIMPORT(char *)           SWIG_PackData(char *, void *, int);
SWIGIMPORT(char *)           SWIG_UnpackData(char *, void *, int);

#else

static swig_type_info *swig_type_list = 0;

/* Check the typename */
SWIGRUNTIME(swig_type_info *) 
SWIG_TypeCheck(char *c, swig_type_info *ty) {
  swig_type_info *s;
  if (!ty) return 0;        /* Void pointer */
  s = ty->next;             /* First element always just a name */
  do {
    if (strcmp(s->name,c) == 0) {
      if (s == ty->next) return s;
      /* Move s to the top of the linked list */
      s->prev->next = s->next;
      if (s->next) {
        s->next->prev = s->prev;
      }
      /* Insert s as second element in the list */
      s->next = ty->next;
      if (ty->next) ty->next->prev = s;
      ty->next = s;
      s->prev = ty;
      return s;
    }
    s = s->next;
  } while (s && (s != ty->next));
  return 0;
}

/* Cast a pointer up an inheritance hierarchy */
SWIGRUNTIME(void *) 
SWIG_TypeCast(swig_type_info *ty, void *ptr) {
  if ((!ty) || (!ty->converter)) return ptr;
  return (*ty->converter)(ptr);
}

/* Return the name associated with this type */
SWIGRUNTIME(const char *)
SWIG_TypeName(const swig_type_info *ty) {
  return ty->name;
}

/* 
   Compare two type names skipping the space characters, therefore
   "char*" == "char *" and "Class<int>" == "Class<int >", etc.

   Return 0 when the two name types are equivalent, as in
   strncmp, but skipping ' '.
*/
static int
SWIG_TypeNameComp(const char *f1, const char *l1,
		  const char *f2, const char *l2) {
  for (;(f1 != l1) && (f2 != l2); ++f1, ++f2) {
    while ((*f1 == ' ') && (f1 != l1)) ++f1;
    while ((*f2 == ' ') && (f2 != l2)) ++f2;
    if (*f1 != *f2) return *f1 - *f2;
  }
  return (l1 - f1) - (l2 - f2);
}

/*
  Check type equivalence in a name list like <name1>|<name2>|...
*/
static int
SWIG_TypeEquiv(const char *nb, const char *tb) {
  int equiv = 0;
  const char* te = tb + strlen(tb);
  const char* ne = nb;
  while (!equiv && *ne) {
    for (nb = ne; *ne; ++ne) {
      if (*ne == '|') break;
    }
    equiv = SWIG_TypeNameComp(nb, ne, tb, te) == 0;
    if (*ne) ++ne;
  }
  return equiv;
}
  

/* Search for a swig_type_info structure */
SWIGRUNTIME(swig_type_info *)
SWIG_TypeQuery(const char *name) {
  swig_type_info *ty = swig_type_list;
  while (ty) {
    if (ty->str && (SWIG_TypeEquiv(ty->str,name))) return ty;
    if (ty->name && (strcmp(name,ty->name) == 0)) return ty;
    ty = ty->prev;
  }
  return 0;
}

/* Pack binary data into a string */
SWIGRUNTIME(char *)
SWIG_PackData(char *c, void *ptr, int sz) {
  static char hex[17] = "0123456789abcdef";
  int i;
  unsigned char *u = (unsigned char *) ptr;
  register unsigned char uu;
  for (i = 0; i < sz; i++,u++) {
    uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}

/* Unpack binary data from a string */
SWIGRUNTIME(char *)
SWIG_UnpackData(char *c, void *ptr, int sz) {
  register unsigned char uu = 0;
  register int d;
  unsigned char *u = (unsigned char *) ptr;
  int i;
  for (i = 0; i < sz; i++, u++) {
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    *u = uu;
  }
  return c;
}

#endif

#ifdef __cplusplus
}
#endif

/***********************************************************************
 * python.swg
 *
 *     This file contains the runtime support for Python modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 * Author : David Beazley (beazley@cs.uchicago.edu)
 ************************************************************************/

#include "Python.h"

#ifdef __cplusplus
extern "C" {
#endif

#define SWIG_PY_INT     1
#define SWIG_PY_FLOAT   2
#define SWIG_PY_STRING  3
#define SWIG_PY_POINTER 4
#define SWIG_PY_BINARY  5

/* Flags for pointer conversion */

#define SWIG_POINTER_EXCEPTION     0x1
#define SWIG_POINTER_DISOWN        0x2

/* Exception handling in wrappers */
#define SWIG_fail   goto fail

/* Constant information structure */
typedef struct swig_const_info {
    int type;
    char *name;
    long lvalue;
    double dvalue;
    void   *pvalue;
    swig_type_info **ptype;
} swig_const_info;

/* Common SWIG API */
#define SWIG_ConvertPtr(obj, pp, type, flags) \
  SWIG_Python_ConvertPtr(obj, pp, type, flags)
#define SWIG_NewPointerObj(p, type, flags) \
  SWIG_Python_NewPointerObj(p, type, flags)
#define SWIG_MustGetPtr(p, type, argnum, flags) \
  SWIG_Python_MustGetPtr(p, type, argnum, flags)
 

typedef double (*py_objasdbl_conv)(PyObject *obj);

#ifdef SWIG_NOINCLUDE

SWIGIMPORT(int)               SWIG_Python_ConvertPtr(PyObject *, void **, swig_type_info *, int);
SWIGIMPORT(PyObject *)        SWIG_Python_NewPointerObj(void *, swig_type_info *,int own);
SWIGIMPORT(void *)            SWIG_Python_MustGetPtr(PyObject *, swig_type_info *, int, int);

#else


/* Convert a pointer value */
SWIGRUNTIME(int)
SWIG_Python_ConvertPtr(PyObject *obj, void **ptr, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  char  *c = 0;
  static PyObject *SWIG_this = 0;
  int    newref = 0;
  PyObject  *pyobj = 0;

  if (!obj) return 0;
  if (obj == Py_None) {
    *ptr = 0;
    return 0;
  }
#ifdef SWIG_COBJECT_TYPES
  if (!(PyCObject_Check(obj))) {
    if (!SWIG_this)
      SWIG_this = PyString_FromString("this");
    pyobj = obj;
    obj = PyObject_GetAttr(obj,SWIG_this);
    newref = 1;
    if (!obj) goto type_error;
    if (!PyCObject_Check(obj)) {
      Py_DECREF(obj);
      goto type_error;
    }
  }  
  *ptr = PyCObject_AsVoidPtr(obj);
  c = (char *) PyCObject_GetDesc(obj);
  if (newref) Py_DECREF(obj);
  goto cobject;
#else
  if (!(PyString_Check(obj))) {
    if (!SWIG_this)
      SWIG_this = PyString_FromString("this");
    pyobj = obj;
    obj = PyObject_GetAttr(obj,SWIG_this);
    newref = 1;
    if (!obj) goto type_error;
    if (!PyString_Check(obj)) {
      Py_DECREF(obj);
      goto type_error;
    }
  } 
  c = PyString_AsString(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') {
    *ptr = (void *) 0;
    if (strcmp(c,"NULL") == 0) {
      if (newref) { Py_DECREF(obj); }
      return 0;
    } else {
      if (newref) { Py_DECREF(obj); }
      goto type_error;
    }
  }
  c++;
  c = SWIG_UnpackData(c,ptr,sizeof(void *));
  if (newref) { Py_DECREF(obj); }
#endif

#ifdef SWIG_COBJECT_TYPES
cobject:
#endif

  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
    *ptr = SWIG_TypeCast(tc,(void*) *ptr);
  }

  if ((pyobj) && (flags & SWIG_POINTER_DISOWN)) {
    PyObject *zero = PyInt_FromLong(0);
    PyObject_SetAttrString(pyobj,(char*)"thisown",zero);
    Py_DECREF(zero);
  }
  return 0;

type_error:
  PyErr_Clear();
  if (flags & SWIG_POINTER_EXCEPTION) {
    if (ty && c) {
      PyErr_Format(PyExc_TypeError, 
		   "Type error. Got %s, expected %s",
		   c, ty->name);
    } else {
      PyErr_SetString(PyExc_TypeError,"Expected a pointer");
    }
  }
  return -1;
}

/* Convert a pointer value, signal an exception on a type mismatch */
SWIGRUNTIME(void *)
SWIG_Python_MustGetPtr(PyObject *obj, swig_type_info *ty, int argnum, int flags) {
  void *result;
  SWIG_Python_ConvertPtr(obj, &result, ty, flags | SWIG_POINTER_EXCEPTION);
  return result;
}

/* Create a new pointer object */
SWIGRUNTIME(PyObject *)
SWIG_Python_NewPointerObj(void *ptr, swig_type_info *type, int own) {
  PyObject *robj;
  if (!ptr) {
    Py_INCREF(Py_None);
    return Py_None;
  }
#ifdef SWIG_COBJECT_TYPES
  robj = PyCObject_FromVoidPtrAndDesc((void *) ptr, (char *) type->name, NULL);
#else
  {
    char result[1024];
    char *r = result;
    *(r++) = '_';
    r = SWIG_PackData(r,&ptr,sizeof(void *));
    strcpy(r,type->name);
    robj = PyString_FromString(result);
  }
#endif
  if (!robj || (robj == Py_None)) return robj;
  if (type->clientdata) {
    PyObject *inst;
    PyObject *args = Py_BuildValue((char*)"(O)", robj);
    Py_DECREF(robj);
    inst = PyObject_CallObject((PyObject *) type->clientdata, args);
    Py_DECREF(args);
    if (inst) {
      if (own) {
        PyObject *n = PyInt_FromLong(1);
        PyObject_SetAttrString(inst,(char*)"thisown",n);
        Py_DECREF(n);
      }
      robj = inst;
    }
  }
  return robj;
}

#endif

#ifdef __cplusplus
}
#endif

"""


######################################################################
# This is for SWIG-1.3.x where x >= 23.
# SWIG_RUNTIME_VERSION == "1"

# All this does is to include (cut/paste): <swigrun.swg>
# <python/pyrun.swg> and <runtime.swg>
swigptr2_code_v1 = """
/***********************************************************************
 * swigrun.swg
 *
 *     This file contains generic CAPI SWIG runtime support for pointer
 *     type checking.
 *
 ************************************************************************/

/* This should only be incremented when either the layout of swig_type_info changes,
   or for whatever reason, the runtime changes incompatibly */
#define SWIG_RUNTIME_VERSION "1"

/* define SWIG_TYPE_TABLE_NAME as "SWIG_TYPE_TABLE" */
#ifdef SWIG_TYPE_TABLE
#define SWIG_QUOTE_STRING(x) #x
#define SWIG_EXPAND_AND_QUOTE_STRING(x) SWIG_QUOTE_STRING(x)
#define SWIG_TYPE_TABLE_NAME SWIG_EXPAND_AND_QUOTE_STRING(SWIG_TYPE_TABLE)
#else
#define SWIG_TYPE_TABLE_NAME
#endif

#include <string.h>

#ifndef SWIGINLINE
#if defined(__cplusplus) || (defined(__GNUC__) && !defined(__STRICT_ANSI__))
#  define SWIGINLINE inline
#else
#  define SWIGINLINE
#endif
#endif

/*
  You can use the SWIGRUNTIME and SWIGRUNTIMEINLINE macros for
  creating a static or dynamic library from the swig runtime code.
  In 99.9% of the cases, swig just needs to declare them as 'static'.
  
  But only do this if is strictly necessary, ie, if you have problems
  with your compiler or so.
*/
#ifndef SWIGRUNTIME
#define SWIGRUNTIME static
#endif
#ifndef SWIGRUNTIMEINLINE
#define SWIGRUNTIMEINLINE SWIGRUNTIME SWIGINLINE
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void *(*swig_converter_func)(void *);
typedef struct swig_type_info *(*swig_dycast_func)(void **);

typedef struct swig_type_info {
  const char             *name;
  swig_converter_func     converter;
  const char             *str;
  void                   *clientdata;
  swig_dycast_func        dcast;
  struct swig_type_info  *next;
  struct swig_type_info  *prev;
} swig_type_info;

/* 
  Compare two type names skipping the space characters, therefore
  "char*" == "char *" and "Class<int>" == "Class<int >", etc.

  Return 0 when the two name types are equivalent, as in
  strncmp, but skipping ' '.
*/
SWIGRUNTIME int
SWIG_TypeNameComp(const char *f1, const char *l1,
		  const char *f2, const char *l2) {
  for (;(f1 != l1) && (f2 != l2); ++f1, ++f2) {
    while ((*f1 == ' ') && (f1 != l1)) ++f1;
    while ((*f2 == ' ') && (f2 != l2)) ++f2;
    if (*f1 != *f2) return *f1 - *f2;
  }
  return (l1 - f1) - (l2 - f2);
}

/*
  Check type equivalence in a name list like <name1>|<name2>|...
*/
SWIGRUNTIME int
SWIG_TypeEquiv(const char *nb, const char *tb) {
  int equiv = 0;
  const char* te = tb + strlen(tb);
  const char* ne = nb;
  while (!equiv && *ne) {
    for (nb = ne; *ne; ++ne) {
      if (*ne == '|') break;
    }
    equiv = SWIG_TypeNameComp(nb, ne, tb, te) == 0;
    if (*ne) ++ne;
  }
  return equiv;
}

/*
  Register a type mapping with the type-checking
*/
SWIGRUNTIME swig_type_info *
SWIG_TypeRegisterTL(swig_type_info **tl, swig_type_info *ti) {
  swig_type_info *tc, *head, *ret, *next;
  /* Check to see if this type has already been registered */
  tc = *tl;
  while (tc) {
    /* check simple type equivalence */
    int typeequiv = (strcmp(tc->name, ti->name) == 0);   
    /* check full type equivalence, resolving typedefs */
    if (!typeequiv) {
      /* only if tc is not a typedef (no '|' on it) */
      if (tc->str && ti->str && !strstr(tc->str,"|")) {
	typeequiv = SWIG_TypeEquiv(ti->str,tc->str);
      }
    }
    if (typeequiv) {
      /* Already exists in the table.  Just add additional types to the list */
      if (ti->clientdata) tc->clientdata = ti->clientdata;
      head = tc;
      next = tc->next;
      goto l1;
    }
    tc = tc->prev;
  }
  head = ti;
  next = 0;

  /* Place in list */
  ti->prev = *tl;
  *tl = ti;

  /* Build linked lists */
  l1:
  ret = head;
  tc = ti + 1;
  /* Patch up the rest of the links */
  while (tc->name) {
    head->next = tc;
    tc->prev = head;
    head = tc;
    tc++;
  }
  if (next) next->prev = head;
  head->next = next;

  return ret;
}

/*
  Check the typename
*/
SWIGRUNTIME swig_type_info *
SWIG_TypeCheck(const char *c, swig_type_info *ty) {
  swig_type_info *s;
  if (!ty) return 0;        /* Void pointer */
  s = ty->next;             /* First element always just a name */
  do {
    if (strcmp(s->name,c) == 0) {
      if (s == ty->next) return s;
      /* Move s to the top of the linked list */
      s->prev->next = s->next;
      if (s->next) {
        s->next->prev = s->prev;
      }
      /* Insert s as second element in the list */
      s->next = ty->next;
      if (ty->next) ty->next->prev = s;
      ty->next = s;
      s->prev = ty;
      return s;
    }
    s = s->next;
  } while (s && (s != ty->next));
  return 0;
}

/*
  Cast a pointer up an inheritance hierarchy
*/
SWIGRUNTIMEINLINE void *
SWIG_TypeCast(swig_type_info *ty, void *ptr) {
  return ((!ty) || (!ty->converter)) ? ptr : (*ty->converter)(ptr);
}

/* 
   Dynamic pointer casting. Down an inheritance hierarchy
*/
SWIGRUNTIME swig_type_info *
SWIG_TypeDynamicCast(swig_type_info *ty, void **ptr) {
  swig_type_info *lastty = ty;
  if (!ty || !ty->dcast) return ty;
  while (ty && (ty->dcast)) {
    ty = (*ty->dcast)(ptr);
    if (ty) lastty = ty;
  }
  return lastty;
}

/*
  Return the name associated with this type
*/
SWIGRUNTIMEINLINE const char *
SWIG_TypeName(const swig_type_info *ty) {
  return ty->name;
}

/*
  Return the pretty name associated with this type,
  that is an unmangled type name in a form presentable to the user.
*/
SWIGRUNTIME const char *
SWIG_TypePrettyName(const swig_type_info *type) {
  /* The "str" field contains the equivalent pretty names of the
     type, separated by vertical-bar characters.  We choose
     to print the last name, as it is often (?) the most
     specific. */
  if (type->str != NULL) {
    const char *last_name = type->str;
    const char *s;
    for (s = type->str; *s; s++)
      if (*s == '|') last_name = s+1;
    return last_name;
  }
  else
    return type->name;
}

/*
  Search for a swig_type_info structure
*/
SWIGRUNTIME swig_type_info *
SWIG_TypeQueryTL(swig_type_info *tl, const char *name) {
  swig_type_info *ty = tl;
  while (ty) {
    if (ty->str && (SWIG_TypeEquiv(ty->str,name))) return ty;
    if (ty->name && (strcmp(name,ty->name) == 0)) return ty;
    ty = ty->prev;
  }
  return 0;
}

/* 
   Set the clientdata field for a type
*/
SWIGRUNTIME void
SWIG_TypeClientDataTL(swig_type_info *tl, swig_type_info *ti, void *clientdata) {
  swig_type_info *tc, *equiv;
  if (ti->clientdata) return;
  /* if (ti->clientdata == clientdata) return; */
  ti->clientdata = clientdata;
  equiv = ti->next;
  while (equiv) {
    if (!equiv->converter) {
      tc = tl;
      while (tc) {
        if ((strcmp(tc->name, equiv->name) == 0))
          SWIG_TypeClientDataTL(tl,tc,clientdata);
        tc = tc->prev;
      }
    }
    equiv = equiv->next;
  }
}

/* 
   Pack binary data into a string
*/
SWIGRUNTIME char *
SWIG_PackData(char *c, void *ptr, size_t sz) {
  static char hex[17] = "0123456789abcdef";
  unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu =  u + sz;
  register unsigned char uu;
  for (; u != eu; ++u) {
    uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}

/* 
   Unpack binary data from a string
*/
SWIGRUNTIME const char *
SWIG_UnpackData(const char *c, void *ptr, size_t sz) {
  register unsigned char *u = (unsigned char *) ptr;
  register const unsigned char *eu =  u + sz;
  for (; u != eu; ++u) {
    register int d = *(c++);
    register unsigned char uu = 0;
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    else 
      return (char *) 0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    else 
      return (char *) 0;
    *u = uu;
  }
  return c;
}

/*
  This function will propagate the clientdata field of type to any new
  swig_type_info structures that have been added into the list of
  equivalent types.  It is like calling SWIG_TypeClientData(type,
  clientdata) a second time.
*/
SWIGRUNTIME void
SWIG_PropagateClientDataTL(swig_type_info *tl, swig_type_info *type) {
  swig_type_info *equiv = type->next;
  swig_type_info *tc;
  if (!type->clientdata) return;
  while (equiv) {
    if (!equiv->converter) {
      tc = tl;
      while (tc) {
        if ((strcmp(tc->name, equiv->name) == 0) && !tc->clientdata)
          SWIG_TypeClientDataTL(tl,tc, type->clientdata);
        tc = tc->prev;
      }
    }
    equiv = equiv->next;
  }
}

/* 
   Pack 'void *' into a string buffer.
*/
SWIGRUNTIME char *
SWIG_PackVoidPtr(char *buff, void *ptr, const char *name, size_t bsz) {
  char *r = buff;
  if ((2*sizeof(void *) + 2) > bsz) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,&ptr,sizeof(void *));
  if (strlen(name) + 1 > (bsz - (r - buff))) return 0;
  strcpy(r,name);
  return buff;
}

SWIGRUNTIME const char *
SWIG_UnpackVoidPtr(const char *c, void **ptr, const char *name) {
  if (*c != '_') {
    if (strcmp(c,"NULL") == 0) {
      *ptr = (void *) 0;
      return name;
    } else {
      return 0;
    }
  }
  return SWIG_UnpackData(++c,ptr,sizeof(void *));
}

SWIGRUNTIME char *
SWIG_PackDataName(char *buff, void *ptr, size_t sz, const char *name, size_t bsz) {
  char *r = buff;
  size_t lname = (name ? strlen(name) : 0);
  if ((2*sz + 2 + lname) > bsz) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  if (lname) {
    strncpy(r,name,lname+1);
  } else {
    *r = 0;
  }
  return buff;
}

SWIGRUNTIME const char *
SWIG_UnpackDataName(const char *c, void *ptr, size_t sz, const char *name) {
  if (*c != '_') {
    if (strcmp(c,"NULL") == 0) {
      memset(ptr,0,sz);
      return name;
    } else {
      return 0;
    }
  }
  return SWIG_UnpackData(++c,ptr,sz);
}

#ifdef __cplusplus
}
#endif

/***********************************************************************
 * pyrun.swg
 *
 *     This file contains the runtime support for Python modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 * Author : David Beazley (beazley@cs.uchicago.edu)
 ************************************************************************/

/* Common SWIG API */
#define SWIG_ConvertPtr(obj, pp, type, flags)    SWIG_Python_ConvertPtr(obj, pp, type, flags)
#define SWIG_NewPointerObj(p, type, flags)       SWIG_Python_NewPointerObj(p, type, flags)
#define SWIG_MustGetPtr(p, type, argnum, flags)  SWIG_Python_MustGetPtr(p, type, argnum, flags)
 

/* Python-specific SWIG API */
#define SWIG_ConvertPacked(obj, ptr, sz, ty, flags)   SWIG_Python_ConvertPacked(obj, ptr, sz, ty, flags)
#define SWIG_NewPackedObj(ptr, sz, type)              SWIG_Python_NewPackedObj(ptr, sz, type)


/* -----------------------------------------------------------------------------
 * Pointer declarations
 * ----------------------------------------------------------------------------- */
/*
  Use SWIG_NO_COBJECT_TYPES to force the use of strings to represent
  C/C++ pointers in the python side. Very useful for debugging, but
  not always safe.
*/
#if !defined(SWIG_NO_COBJECT_TYPES) && !defined(SWIG_COBJECT_TYPES)
#  define SWIG_COBJECT_TYPES
#endif

/* Flags for pointer conversion */
#define SWIG_POINTER_EXCEPTION     0x1
#define SWIG_POINTER_DISOWN        0x2


#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------------
 * Create a new pointer string 
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_BUFFER_SIZE
#define SWIG_BUFFER_SIZE 1024
#endif

#if defined(SWIG_COBJECT_TYPES)
#if !defined(SWIG_COBJECT_PYTHON)
/* -----------------------------------------------------------------------------
 * Implements a simple Swig Object type, and use it instead of PyCObject
 * ----------------------------------------------------------------------------- */

typedef struct {
  PyObject_HEAD
  void *ptr;
  const char *desc;
} PySwigObject;

/* Declarations for objects of type PySwigObject */

SWIGRUNTIME int
PySwigObject_print(PySwigObject *v, FILE *fp, int flags)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackVoidPtr(result, v->ptr, v->desc, sizeof(result))) {
    fputs("<Swig Object at ", fp); fputs(result, fp); fputs(">", fp);
    return 0; 
  } else {
    return 1; 
  }
}
  
SWIGRUNTIME PyObject *
PySwigObject_repr(PySwigObject *v)
{
  char result[SWIG_BUFFER_SIZE];
  return SWIG_PackVoidPtr(result, v->ptr, v->desc, sizeof(result)) ?
    PyString_FromFormat("<Swig Object at %s>", result) : 0;
}

SWIGRUNTIME PyObject *
PySwigObject_str(PySwigObject *v)
{
  char result[SWIG_BUFFER_SIZE];
  return SWIG_PackVoidPtr(result, v->ptr, v->desc, sizeof(result)) ?
    PyString_FromString(result) : 0;
}

SWIGRUNTIME PyObject *
PySwigObject_long(PySwigObject *v)
{
  return PyLong_FromUnsignedLong((unsigned long) v->ptr);
}

SWIGRUNTIME PyObject *
PySwigObject_oct(PySwigObject *v)
{
  char buf[100];
  unsigned long x = (unsigned long)v->ptr;
  if (x == 0)
    strcpy(buf, "0");
  else
    PyOS_snprintf(buf, sizeof(buf), "0%lo", x);
  return PyString_FromString(buf);
}

SWIGRUNTIME PyObject *
PySwigObject_hex(PySwigObject *v)
{
  char buf[100];
  PyOS_snprintf(buf, sizeof(buf), "0x%lx", (unsigned long)v->ptr);
  return PyString_FromString(buf);
}

SWIGRUNTIME int
PySwigObject_compare(PySwigObject *v, PySwigObject *w)
{
  int c = strcmp(v->desc, w->desc);
  if (c) {
    return c;
  } else {
    void *i = v->ptr;
    void *j = w->ptr;
    return (i < j) ? -1 : (i > j) ? 1 : 0;
  }
}

SWIGRUNTIME void
PySwigObject_dealloc(PySwigObject *self)
{
  PyObject_DEL(self);
}

SWIGRUNTIME PyTypeObject*
PySwigObject_GetType() {
  static char PySwigObject_Type__doc__[] = 
    "Swig object carries a C/C++ instance pointer";
  
  static PyNumberMethods PySwigObject_as_number = {
    (binaryfunc)0, /*nb_add*/
    (binaryfunc)0, /*nb_subtract*/
    (binaryfunc)0, /*nb_multiply*/
    (binaryfunc)0, /*nb_divide*/
    (binaryfunc)0, /*nb_remainder*/
    (binaryfunc)0, /*nb_divmod*/
    (ternaryfunc)0,/*nb_power*/
    (unaryfunc)0,  /*nb_negative*/
    (unaryfunc)0,  /*nb_positive*/
    (unaryfunc)0,  /*nb_absolute*/
    (inquiry)0,    /*nb_nonzero*/
    0,		   /*nb_invert*/
    0,		   /*nb_lshift*/
    0,		   /*nb_rshift*/
    0,		   /*nb_and*/
    0,		   /*nb_xor*/
    0,		   /*nb_or*/
    (coercion)0,   /*nb_coerce*/
    (unaryfunc)PySwigObject_long, /*nb_int*/
    (unaryfunc)PySwigObject_long, /*nb_long*/
    (unaryfunc)0,                 /*nb_float*/
    (unaryfunc)PySwigObject_oct,  /*nb_oct*/
    (unaryfunc)PySwigObject_hex,  /*nb_hex*/
#if PY_VERSION_HEX >= 0x02000000
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /* nb_inplace_add -> nb_inplace_true_divide */ 
#endif
  };

  static PyTypeObject PySwigObject_Type = {
    PyObject_HEAD_INIT(&PyType_Type)
    0,					/*ob_size*/
    "PySwigObject",			/*tp_name*/
    sizeof(PySwigObject),		/*tp_basicsize*/
    0,					/*tp_itemsize*/
    /* methods */
    (destructor)PySwigObject_dealloc,	/*tp_dealloc*/
    (printfunc)PySwigObject_print,	/*tp_print*/
    (getattrfunc)0,			/*tp_getattr*/
    (setattrfunc)0,			/*tp_setattr*/
    (cmpfunc)PySwigObject_compare,	/*tp_compare*/
    (reprfunc)PySwigObject_repr,	/*tp_repr*/
    &PySwigObject_as_number,	        /*tp_as_number*/
    0,					/*tp_as_sequence*/
    0,					/*tp_as_mapping*/
    (hashfunc)0,			/*tp_hash*/
    (ternaryfunc)0,			/*tp_call*/
    (reprfunc)PySwigObject_str,		/*tp_str*/
    /* Space for future expansion */
    0L,0L,0L,0L,
    PySwigObject_Type__doc__, 	        /* Documentation string */
#if PY_VERSION_HEX >= 0x02000000
    0,                                  /* tp_traverse */
    0,                                  /* tp_clear */
#endif
#if PY_VERSION_HEX >= 0x02010000
    0,                                  /* tp_richcompare */
    0,                                  /* tp_weaklistoffset */
#endif
#if PY_VERSION_HEX >= 0x02020000
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* tp_iter -> tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
    0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
    0,0,0,0                             /* tp_alloc -> tp_next */
#endif
  };

  return &PySwigObject_Type;
}

SWIGRUNTIME PyObject *
PySwigObject_FromVoidPtrAndDesc(void *ptr, const char *desc)
{
  PySwigObject *self = PyObject_NEW(PySwigObject, PySwigObject_GetType());
  if (self == NULL) return NULL;
  self->ptr = ptr;
  self->desc = desc;
  return (PyObject *)self;
}

SWIGRUNTIMEINLINE void *
PySwigObject_AsVoidPtr(PyObject *self)
{
  return ((PySwigObject *)self)->ptr;
}

SWIGRUNTIMEINLINE const char *
PySwigObject_GetDesc(PyObject *self)
{
  return ((PySwigObject *)self)->desc;
}

SWIGRUNTIMEINLINE int
PySwigObject_Check(PyObject *op) {
  return ((op)->ob_type == PySwigObject_GetType()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigObject") == 0);
}

/* -----------------------------------------------------------------------------
 * Implements a simple Swig Packed type, and use it instead of string
 * ----------------------------------------------------------------------------- */

typedef struct {
  PyObject_HEAD
  void *pack;
  const char *desc;
  size_t size;
} PySwigPacked;

SWIGRUNTIME int
PySwigPacked_print(PySwigPacked *v, FILE *fp, int flags)
{
  char result[SWIG_BUFFER_SIZE];
  fputs("<Swig Packed ", fp); 
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    fputs("at ", fp); 
    fputs(result, fp); 
  }
  fputs(v->desc,fp); 
  fputs(">", fp);
  return 0; 
}
  
SWIGRUNTIME PyObject *
PySwigPacked_repr(PySwigPacked *v)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    return PyString_FromFormat("<Swig Packed at %s%s>", result, v->desc);
  } else {
    return PyString_FromFormat("<Swig Packed %s>", v->desc);
  }  
}

SWIGRUNTIME PyObject *
PySwigPacked_str(PySwigPacked *v)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))){
    return PyString_FromFormat("%s%s", result, v->desc);
  } else {
    return PyString_FromFormat("%s", v->desc);
  }  
}

SWIGRUNTIME int
PySwigPacked_compare(PySwigPacked *v, PySwigPacked *w)
{
  int c = strcmp(v->desc, w->desc);
  if (c) {
    return c;
  } else {
    size_t i = v->size;
    size_t j = w->size;
    int s = (i < j) ? -1 : (i > j) ? 1 : 0;
    return s ? s : strncmp((char *)v->pack, (char *)w->pack, 2*v->size);
  }
}

SWIGRUNTIME void
PySwigPacked_dealloc(PySwigPacked *self)
{
  free(self->pack);
  PyObject_DEL(self);
}

SWIGRUNTIME PyTypeObject*
PySwigPacked_GetType() {
  static char PySwigPacked_Type__doc__[] = 
    "Swig object carries a C/C++ instance pointer";
  
  static PyTypeObject PySwigPacked_Type = {
    PyObject_HEAD_INIT(&PyType_Type)
    0,					/*ob_size*/
    "PySwigPacked",			/*tp_name*/
    sizeof(PySwigPacked),		/*tp_basicsize*/
    0,					/*tp_itemsize*/
    /* methods */
    (destructor)PySwigPacked_dealloc,	/*tp_dealloc*/
    (printfunc)PySwigPacked_print,	/*tp_print*/
    (getattrfunc)0,			/*tp_getattr*/
    (setattrfunc)0,			/*tp_setattr*/
    (cmpfunc)PySwigPacked_compare,	/*tp_compare*/
    (reprfunc)PySwigPacked_repr,	/*tp_repr*/
    0,	                                /*tp_as_number*/
    0,					/*tp_as_sequence*/
    0,					/*tp_as_mapping*/
    (hashfunc)0,			/*tp_hash*/
    (ternaryfunc)0,			/*tp_call*/
    (reprfunc)PySwigPacked_str,		/*tp_str*/
    /* Space for future expansion */
    0L,0L,0L,0L,
    PySwigPacked_Type__doc__, 	        /* Documentation string */
#if PY_VERSION_HEX >= 0x02000000
    0,                                  /* tp_traverse */
    0,                                  /* tp_clear */
#endif
#if PY_VERSION_HEX >= 0x02010000
    0,                                  /* tp_richcompare */
    0,                                  /* tp_weaklistoffset */
#endif
#if PY_VERSION_HEX >= 0x02020000         
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* tp_iter -> tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
    0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
    0,0,0,0                             /* tp_alloc -> tp_next */
#endif
  };

  return &PySwigPacked_Type;
}

SWIGRUNTIME PyObject *
PySwigPacked_FromDataAndDesc(void *ptr, size_t size, const char *desc)
{
  PySwigPacked *self = PyObject_NEW(PySwigPacked, PySwigPacked_GetType());
  if (self == NULL) {
    return NULL;
  } else {
    void *pack = malloc(size);
    memcpy(pack, ptr, size);
    self->pack = pack;
    self->desc = desc;
    self->size = size;
    return (PyObject *) self;
  }
}

SWIGRUNTIMEINLINE const char *
PySwigPacked_UnpackData(PyObject *obj, void *ptr, size_t size)
{
  PySwigPacked *self = (PySwigPacked *)obj;
  if (self->size != size) return 0;
  memcpy(ptr, self->pack, size);
  return self->desc;
}

SWIGRUNTIMEINLINE const char *
PySwigPacked_GetDesc(PyObject *self)
{
  return ((PySwigPacked *)self)->desc;
}

SWIGRUNTIMEINLINE int
PySwigPacked_Check(PyObject *op) {
  return ((op)->ob_type == PySwigPacked_GetType()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigPacked") == 0);
}

#else
/* -----------------------------------------------------------------------------
 * Use the old Python PyCObject instead of PySwigObject
 * ----------------------------------------------------------------------------- */

#define PySwigObject_GetDesc(obj)	           PyCObject_GetDesc(obj)
#define PySwigObject_Check(obj)	           PyCObject_Check(obj)
#define PySwigObject_AsVoidPtr(obj)	   PyCObject_AsVoidPtr(obj)
#define PySwigObject_FromVoidPtrAndDesc(p, d)  PyCObject_FromVoidPtrAndDesc(p, d, NULL)

#endif

#endif

/* -----------------------------------------------------------------------------
 * errors manipulation
 * ----------------------------------------------------------------------------- */

SWIGRUNTIME void
SWIG_Python_TypeError(const char *type, PyObject *obj)
{
  if (type) {
#if defined(SWIG_COBJECT_TYPES)
    if (PySwigObject_Check(obj)) {
      const char *otype = (const char *) PySwigObject_GetDesc(obj);
      if (otype) {
	PyErr_Format(PyExc_TypeError, "a '%s' is expected, 'PySwigObject(%s)' is received",
		     type, otype);
	return;
      }
    } else 
#endif      
    {
      const char *otype = (obj ? obj->ob_type->tp_name : 0); 
      if (otype) {
	PyObject *str = PyObject_Str(obj);
	const char *cstr = str ? PyString_AsString(str) : 0;
	if (cstr) {
	  PyErr_Format(PyExc_TypeError, "a '%s' is expected, '%s(%s)' is received",
		       type, otype, cstr);
	} else {
	  PyErr_Format(PyExc_TypeError, "a '%s' is expected, '%s' is received",
		       type, otype);
	}
	Py_DECREF(str);
	return;
      }
    }   
    PyErr_Format(PyExc_TypeError, "a '%s' is expected", type);
  } else {
    PyErr_Format(PyExc_TypeError, "unexpected type is received");
  }
}

SWIGRUNTIMEINLINE void
SWIG_Python_NullRef(const char *type)
{
  if (type) {
    PyErr_Format(PyExc_TypeError, "null reference of type '%s' was received",type);
  } else {
    PyErr_Format(PyExc_TypeError, "null reference was received");
  }
}

SWIGRUNTIME int
SWIG_Python_AddErrMesg(const char* mesg, int infront)
{
  if (PyErr_Occurred()) {
    PyObject *type = 0;
    PyObject *value = 0;
    PyObject *traceback = 0;
    PyErr_Fetch(&type, &value, &traceback);
    if (value) {
      PyObject *old_str = PyObject_Str(value);
      Py_XINCREF(type);
      PyErr_Clear();
      if (infront) {
	PyErr_Format(type, "%s %s", mesg, PyString_AsString(old_str));
      } else {
	PyErr_Format(type, "%s %s", PyString_AsString(old_str), mesg);
      }
      Py_DECREF(old_str);
    }
    return 1;
  } else {
    return 0;
  }
}

SWIGRUNTIME int
SWIG_Python_ArgFail(int argnum)
{
  if (PyErr_Occurred()) {
    /* add information about failing argument */
    char mesg[256];
    sprintf(mesg, "argument number %d:", argnum);
    return SWIG_Python_AddErrMesg(mesg, 1);
  } else {
    return 0;
  }
}


/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

/* Convert a pointer value */
SWIGRUNTIME int
SWIG_Python_ConvertPtr(PyObject *obj, void **ptr, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  const char *c = 0;
  static PyObject *SWIG_this = 0;
  int    newref = 0;
  PyObject  *pyobj = 0;
  void *vptr;
  
  if (!obj) return 0;
  if (obj == Py_None) {
    *ptr = 0;
    return 0;
  }

#ifdef SWIG_COBJECT_TYPES
  if (!(PySwigObject_Check(obj))) {
    if (!SWIG_this)
      SWIG_this = PyString_FromString("this");
    pyobj = obj;
    obj = PyObject_GetAttr(obj,SWIG_this);
    newref = 1;
    if (!obj) goto type_error;
    if (!PySwigObject_Check(obj)) {
      Py_DECREF(obj);
      goto type_error;
    }
  }  
  vptr = PySwigObject_AsVoidPtr(obj);
  c = (const char *) PySwigObject_GetDesc(obj);
  if (newref) { Py_DECREF(obj); }
  goto type_check;
#else
  if (!(PyString_Check(obj))) {
    if (!SWIG_this)
      SWIG_this = PyString_FromString("this");
    pyobj = obj;
    obj = PyObject_GetAttr(obj,SWIG_this);
    newref = 1;
    if (!obj) goto type_error;
    if (!PyString_Check(obj)) {
      Py_DECREF(obj);
      goto type_error;
    }
  } 
  c = PyString_AS_STRING(obj);
  /* Pointer values must start with leading underscore */
  c = SWIG_UnpackVoidPtr(c, &vptr, ty->name);
  if (newref) { Py_DECREF(obj); }
  if (!c) goto type_error;
#endif

type_check:

  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
    *ptr = SWIG_TypeCast(tc,vptr);
  }

  if ((pyobj) && (flags & SWIG_POINTER_DISOWN)) {
    PyObject_SetAttrString(pyobj,(char*)"thisown",Py_False);
  }
  return 0;

type_error:
  PyErr_Clear();
  if (pyobj && !obj) {    
    obj = pyobj;
    if (PyCFunction_Check(obj)) {
      /* here we get the method pointer for callbacks */
      char *doc = (((PyCFunctionObject *)obj) -> m_ml -> ml_doc);
      c = doc ? strstr(doc, "swig_ptr: ") : 0;
      if (c) {
	c = SWIG_UnpackVoidPtr(c + 10, &vptr, ty->name);
	if (!c) goto type_error;
	goto type_check;
      }
    }
  }
  if (flags & SWIG_POINTER_EXCEPTION) {
    if (ty) {
      SWIG_Python_TypeError(SWIG_TypePrettyName(ty), obj);
    } else {
      SWIG_Python_TypeError("C/C++ pointer", obj);
    }
  }
  return -1;
}

/* Convert a pointer value, signal an exception on a type mismatch */
SWIGRUNTIME void *
SWIG_Python_MustGetPtr(PyObject *obj, swig_type_info *ty, int argnum, int flags) {
  void *result;
  if (SWIG_Python_ConvertPtr(obj, &result, ty, flags) == -1) {
    PyErr_Clear();
    if (flags & SWIG_POINTER_EXCEPTION) {
      SWIG_Python_TypeError(SWIG_TypePrettyName(ty), obj);
      SWIG_Python_ArgFail(argnum);
    }
  }
  return result;
}

/* Convert a packed value value */
SWIGRUNTIME int
SWIG_Python_ConvertPacked(PyObject *obj, void *ptr, size_t sz, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  const char *c = 0;

#if defined(SWIG_COBJECT_TYPES) && !defined(SWIG_COBJECT_PYTHON)
  c = PySwigPacked_UnpackData(obj, ptr, sz);
#else
  if ((!obj) || (!PyString_Check(obj))) goto type_error;
  c = PyString_AS_STRING(obj);
  /* Pointer values must start with leading underscore */
  c = SWIG_UnpackDataName(c, ptr, sz, ty->name);
#endif
  if (!c) goto type_error;
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
  }
  return 0;

type_error:
  PyErr_Clear();
  if (flags & SWIG_POINTER_EXCEPTION) {
    if (ty) {
      SWIG_Python_TypeError(SWIG_TypePrettyName(ty), obj);
    } else {
      SWIG_Python_TypeError("C/C++ packed data", obj);
    }
  }
  return -1;
}  

/* Create a new array object */
SWIGRUNTIME PyObject *
SWIG_Python_NewPointerObj(void *ptr, swig_type_info *type, int own) {
  PyObject *robj = 0;
  if (!ptr) {
    Py_INCREF(Py_None);
    return Py_None;
  }
#ifdef SWIG_COBJECT_TYPES
  robj = PySwigObject_FromVoidPtrAndDesc((void *) ptr, (char *)type->name);
#else
  {
    char result[SWIG_BUFFER_SIZE];
    robj = SWIG_PackVoidPtr(result, ptr, type->name, sizeof(result)) ?
      PyString_FromString(result) : 0;
  }
#endif
  if (!robj || (robj == Py_None)) return robj;
  if (type->clientdata) {
    PyObject *inst;
    PyObject *args = Py_BuildValue((char*)"(O)", robj);
    Py_DECREF(robj);
    inst = PyObject_CallObject((PyObject *) type->clientdata, args);
    Py_DECREF(args);
    if (inst) {
      if (own) {
        PyObject_SetAttrString(inst,(char*)"thisown",Py_True);
      }
      robj = inst;
    }
  }
  return robj;
}

SWIGRUNTIME PyObject *
SWIG_Python_NewPackedObj(void *ptr, size_t sz, swig_type_info *type) {
  PyObject *robj = 0;
  if (!ptr) {
    Py_INCREF(Py_None);
    return Py_None;
  }
#if defined(SWIG_COBJECT_TYPES) && !defined(SWIG_COBJECT_PYTHON)
  robj = PySwigPacked_FromDataAndDesc((void *) ptr, sz, (char *)type->name);
#else
  {
    char result[SWIG_BUFFER_SIZE];
    robj = SWIG_PackDataName(result, ptr, sz, type->name, sizeof(result)) ?
      PyString_FromString(result) : 0;
  }
#endif
  return robj;
}

/* -----------------------------------------------------------------------------*
 *  Get type list 
 * -----------------------------------------------------------------------------*/

#ifdef SWIG_LINK_RUNTIME
void *SWIG_ReturnGlobalTypeList(void *);
#endif

SWIGRUNTIME swig_type_info **
SWIG_Python_GetTypeListHandle() {
  static void *type_pointer = (void *)0;
  /* first check if module already created */
  if (!type_pointer) {
#ifdef SWIG_LINK_RUNTIME
    type_pointer = SWIG_ReturnGlobalTypeList((void *)0);
#else
    type_pointer = PyCObject_Import((char*)"swig_runtime_data" SWIG_RUNTIME_VERSION,
				    (char*)"type_pointer" SWIG_TYPE_TABLE_NAME);
    if (PyErr_Occurred()) {
      PyErr_Clear();
      type_pointer = (void *)0;
    }
  }
#endif
  return (swig_type_info **) type_pointer;
}

/*
  Search for a swig_type_info structure
 */
SWIGRUNTIMEINLINE swig_type_info *
SWIG_Python_GetTypeList() {
  swig_type_info **tlh = SWIG_Python_GetTypeListHandle();
  return tlh ? *tlh : (swig_type_info*)0;
}

#define SWIG_Runtime_GetTypeList SWIG_Python_GetTypeList 

#ifdef __cplusplus
}
#endif

/* -----------------------------------------------------------------------------*
   Standard SWIG API for use inside user code.
 
   You need to include in your code as follow:

#include <Python.h>            // or using your favorite language 
#include <swigrun.swg>
#include <python/pyrun.swg>    // or using your favorite language 
#include <runtime.swg>
 
 * -----------------------------------------------------------------------------*/

SWIGRUNTIMEINLINE swig_type_info *
SWIG_Runtime_TypeQuery(const char *name) {
  swig_type_info *tl = SWIG_Runtime_GetTypeList();
  return SWIG_TypeQueryTL(tl, name);
}

SWIGRUNTIMEINLINE swig_type_info *
SWIG_Runtime_TypeRegister(swig_type_info *ti) {
  swig_type_info *tl = SWIG_Runtime_GetTypeList();
  return SWIG_TypeRegisterTL(&tl, ti);
}

SWIGRUNTIMEINLINE void
SWIG_Runtime_TypeClientData(swig_type_info *ti, void *clientdata) {
  swig_type_info *tl = SWIG_Runtime_GetTypeList();
  SWIG_TypeClientDataTL(tl, ti, clientdata);
}

SWIGRUNTIMEINLINE void
SWIG_Runtime_PropagateClientData(swig_type_info *type) {
  swig_type_info *tl = SWIG_Runtime_GetTypeList();
  SWIG_PropagateClientDataTL(tl, type);
}

#define SWIG_GetTypeList()            SWIG_Runtime_GetTypeList()
#define SWIG_TypeQuery(name)          SWIG_Runtime_TypeQuery(name)
#define SWIG_TypeRegister(ti)         SWIG_Runtime_TypeRegister(ti)
#define SWIG_TypeClientData(ti, cd)   SWIG_Runtime_TypeClientData(ti, cd)
#define SWIG_PropagateClientData(ti)  SWIG_Runtime_PropagateClientData(ti)

"""

######################################################################
# This is for SWIG-1.3.x where x >= 25.
# SWIG_RUNTIME_VERSION == "2"

# All this does is to include the contents of the file generated by
# this command:
#   swig -python -external-runtime
swigptr2_code_v2 = """
/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 1.3.28
 * 
 * This file is not intended to be easily readable and contains a number of 
 * coding conventions designed to improve portability and efficiency. Do not make
 * changes to this file unless you know what you are doing--modify the SWIG 
 * interface file instead. 
 * ----------------------------------------------------------------------------- */

/***********************************************************************
 *
 *  This section contains generic SWIG labels for method/variable
 *  declarations/attributes, and other compiler dependent labels.
 *
 ************************************************************************/

/* template workaround for compilers that cannot correctly implement the C++ standard */
#ifndef SWIGTEMPLATEDISAMBIGUATOR
# if defined(__SUNPRO_CC)
#   if (__SUNPRO_CC <= 0x560)
#     define SWIGTEMPLATEDISAMBIGUATOR template
#   else
#     define SWIGTEMPLATEDISAMBIGUATOR 
#   endif
# else
#   define SWIGTEMPLATEDISAMBIGUATOR 
# endif
#endif

/* inline attribute */
#ifndef SWIGINLINE
# if defined(__cplusplus) || (defined(__GNUC__) && !defined(__STRICT_ANSI__))
#   define SWIGINLINE inline
# else
#   define SWIGINLINE
# endif
#endif

/* attribute recognised by some compilers to avoid 'unused' warnings */
#ifndef SWIGUNUSED
# if defined(__GNUC__)
#   if !(defined(__cplusplus)) || (__GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4))
#     define SWIGUNUSED __attribute__ ((__unused__)) 
#   else
#     define SWIGUNUSED
#   endif
# elif defined(__ICC)
#   define SWIGUNUSED __attribute__ ((__unused__)) 
# else
#   define SWIGUNUSED 
# endif
#endif

#ifndef SWIGUNUSEDPARM
# ifdef __cplusplus
#   define SWIGUNUSEDPARM(p)
# else
#   define SWIGUNUSEDPARM(p) p SWIGUNUSED 
# endif
#endif

/* internal SWIG method */
#ifndef SWIGINTERN
# define SWIGINTERN static SWIGUNUSED
#endif

/* internal inline SWIG method */
#ifndef SWIGINTERNINLINE
# define SWIGINTERNINLINE SWIGINTERN SWIGINLINE
#endif

/* exporting methods for Windows DLLs */
#ifndef SWIGEXPORT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define SWIGEXPORT
#   else
#     define SWIGEXPORT __declspec(dllexport)
#   endif
# else
#   define SWIGEXPORT
# endif
#endif

/* calling conventions for Windows */
#ifndef SWIGSTDCALL
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   define SWIGSTDCALL __stdcall
# else
#   define SWIGSTDCALL
# endif 
#endif


/*  Errors in SWIG */
#define  SWIG_UnknownError    	   -1 
#define  SWIG_IOError        	   -2 
#define  SWIG_RuntimeError   	   -3 
#define  SWIG_IndexError     	   -4 
#define  SWIG_TypeError      	   -5 
#define  SWIG_DivisionByZero 	   -6 
#define  SWIG_OverflowError  	   -7 
#define  SWIG_SyntaxError    	   -8 
#define  SWIG_ValueError     	   -9 
#define  SWIG_SystemError    	   -10
#define  SWIG_AttributeError 	   -11
#define  SWIG_MemoryError    	   -12 
#define  SWIG_NullReferenceError   -13



/***********************************************************************
 * swigrun.swg
 *
 *     This file contains generic CAPI SWIG runtime support for pointer
 *     type checking.
 *
 ************************************************************************/

/* This should only be incremented when either the layout of swig_type_info changes,
   or for whatever reason, the runtime changes incompatibly */
#define SWIG_RUNTIME_VERSION "2"

/* define SWIG_TYPE_TABLE_NAME as "SWIG_TYPE_TABLE" */
#ifdef SWIG_TYPE_TABLE
# define SWIG_QUOTE_STRING(x) #x
# define SWIG_EXPAND_AND_QUOTE_STRING(x) SWIG_QUOTE_STRING(x)
# define SWIG_TYPE_TABLE_NAME SWIG_EXPAND_AND_QUOTE_STRING(SWIG_TYPE_TABLE)
#else
# define SWIG_TYPE_TABLE_NAME
#endif

/*
  You can use the SWIGRUNTIME and SWIGRUNTIMEINLINE macros for
  creating a static or dynamic library from the swig runtime code.
  In 99.9% of the cases, swig just needs to declare them as 'static'.
  
  But only do this if is strictly necessary, ie, if you have problems
  with your compiler or so.
*/

#ifndef SWIGRUNTIME
# define SWIGRUNTIME SWIGINTERN
#endif

#ifndef SWIGRUNTIMEINLINE
# define SWIGRUNTIMEINLINE SWIGRUNTIME SWIGINLINE
#endif

/*  Generic buffer size */
#ifndef SWIG_BUFFER_SIZE
# define SWIG_BUFFER_SIZE 1024
#endif

/* Flags for pointer conversions */
#define SWIG_POINTER_DISOWN        0x1

/* Flags for new pointer objects */
#define SWIG_POINTER_OWN           0x1


/* 
   Flags/methods for returning states.
   
   The swig conversion methods, as ConvertPtr, return and integer 
   that tells if the conversion was successful or not. And if not,
   an error code can be returned (see swigerrors.swg for the codes).
   
   Use the following macros/flags to set or process the returning
   states.
   
   In old swig versions, you usually write code as:

     if (SWIG_ConvertPtr(obj,vptr,ty.flags) != -1) {
       // success code
     } else {
       //fail code
     }

   Now you can be more explicit as:

    int res = SWIG_ConvertPtr(obj,vptr,ty.flags);
    if (SWIG_IsOK(res)) {
      // success code
    } else {
      // fail code
    }

   that seems to be the same, but now you can also do

    Type *ptr;
    int res = SWIG_ConvertPtr(obj,(void **)(&ptr),ty.flags);
    if (SWIG_IsOK(res)) {
      // success code
      if (SWIG_IsNewObj(res) {
        ...
	delete *ptr;
      } else {
        ...
      }
    } else {
      // fail code
    }
    
   I.e., now SWIG_ConvertPtr can return new objects and you can
   identify the case and take care of the deallocation. Of course that
   requires also to SWIG_ConvertPtr to return new result values, as

      int SWIG_ConvertPtr(obj, ptr,...) {         
        if (<obj is ok>) {			       
          if (<need new object>) {		       
            *ptr = <ptr to new allocated object>; 
            return SWIG_NEWOBJ;		       
          } else {				       
            *ptr = <ptr to old object>;	       
            return SWIG_OLDOBJ;		       
          } 				       
        } else {				       
          return SWIG_BADOBJ;		       
        }					       
      }

   Of course, returning the plain '0(success)/-1(fail)' still works, but you can be
   more explicit by returning SWIG_BADOBJ, SWIG_ERROR or any of the
   swig errors code.

   Finally, if the SWIG_CASTRANK_MODE is enabled, the result code
   allows to return the 'cast rank', for example, if you have this

       int food(double)
       int fooi(int);

   and you call
 
      food(1)   // cast rank '1'  (1 -> 1.0)
      fooi(1)   // cast rank '0'

   just use the SWIG_AddCast()/SWIG_CheckState()


 */
#define SWIG_OK                    (0) 
#define SWIG_ERROR                 (-1)
#define SWIG_IsOK(r)               (r >= 0)

/* The CastRankLimit says how many bits are used for the cast rank */
#define SWIG_CASTRANKLIMIT         (1 << 8)
/* The NewMask denotes the object was created (using new/malloc) */
#define SWIG_NEWOBJMASK            (SWIG_CASTRANKLIMIT  << 1)
/* The TmpMask is for in/out typemaps that use temporal objects */
#define SWIG_TMPOBJMASK            (SWIG_NEWOBJMASK << 1)
/* Simple returning values */
#define SWIG_BADOBJ                (SWIG_ERROR)
#define SWIG_OLDOBJ                (SWIG_OK)
#define SWIG_NEWOBJ                (SWIG_OK | SWIG_NEWOBJMASK)
#define SWIG_TMPOBJ                (SWIG_OK | SWIG_TMPOBJMASK)
/* Check, add and del mask methods */
#define SWIG_AddNewMask(r)         (SWIG_IsOK(r) ? (r | SWIG_NEWOBJMASK) : r)
#define SWIG_DelNewMask(r)         (SWIG_IsOK(r) ? (r & ~SWIG_NEWOBJMASK) : r)
#define SWIG_IsNewObj(r)           (SWIG_IsOK(r) && (r & SWIG_NEWOBJMASK))
#define SWIG_AddTmpMask(r)         (SWIG_IsOK(r) ? (r | SWIG_TMPOBJMASK) : r)
#define SWIG_DelTmpMask(r)         (SWIG_IsOK(r) ? (r & ~SWIG_TMPOBJMASK) : r)
#define SWIG_IsTmpObj(r)           (SWIG_IsOK(r) && (r & SWIG_TMPOBJMASK))


/* Cast-Rank Mode */
#if defined(SWIG_CASTRANK_MODE)
#  ifndef SWIG_TypeRank
#    define SWIG_TypeRank             unsigned long
#  endif
#  ifndef SWIG_MAXCASTRANK            /* Default cast allowed */
#    define SWIG_MAXCASTRANK          (2)
#  endif
#  define SWIG_CASTRANKMASK          ((SWIG_CASTRANKLIMIT) -1)
#  define SWIG_CastRank(r)           (r & SWIG_CASTRANKMASK)
SWIGINTERNINLINE int SWIG_AddCast(int r) { 
  return SWIG_IsOK(r) ? ((SWIG_CastRank(r) < SWIG_MAXCASTRANK) ? (r + 1) : SWIG_ERROR) : r;
}
SWIGINTERNINLINE int SWIG_CheckState(int r) { 
  return SWIG_IsOK(r) ? SWIG_CastRank(r) + 1 : 0; 
}
#else /* no cast-rank mode */
#  define SWIG_AddCast
#  define SWIG_CheckState(r) (SWIG_IsOK(r) ? 1 : 0)
#endif




#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *(*swig_converter_func)(void *);
typedef struct swig_type_info *(*swig_dycast_func)(void **);

/* Structure to store inforomation on one type */
typedef struct swig_type_info {
  const char             *name;			/* mangled name of this type */
  const char             *str;			/* human readable name of this type */
  swig_dycast_func        dcast;		/* dynamic cast function down a hierarchy */
  struct swig_cast_info  *cast;			/* linked list of types that can cast into this type */
  void                   *clientdata;		/* language specific type data */
  int                    owndata;		/* flag if the structure owns the clientdata */
} swig_type_info;

/* Structure to store a type and conversion function used for casting */
typedef struct swig_cast_info {
  swig_type_info         *type;			/* pointer to type that is equivalent to this type */
  swig_converter_func     converter;		/* function to cast the void pointers */
  struct swig_cast_info  *next;			/* pointer to next cast in linked list */
  struct swig_cast_info  *prev;			/* pointer to the previous cast */
} swig_cast_info;

/* Structure used to store module information
 * Each module generates one structure like this, and the runtime collects
 * all of these structures and stores them in a circularly linked list.*/
typedef struct swig_module_info {
  swig_type_info         **types;		/* Array of pointers to swig_type_info structures that are in this module */
  size_t                 size;		        /* Number of types in this module */
  struct swig_module_info *next;		/* Pointer to next element in circularly linked list */
  swig_type_info         **type_initial;	/* Array of initially generated type structures */
  swig_cast_info         **cast_initial;	/* Array of initially generated casting structures */
  void                    *clientdata;		/* Language specific module data */
} swig_module_info;

/* 
  Compare two type names skipping the space characters, therefore
  "char*" == "char *" and "Class<int>" == "Class<int >", etc.

  Return 0 when the two name types are equivalent, as in
  strncmp, but skipping ' '.
*/
SWIGRUNTIME int
SWIG_TypeNameComp(const char *f1, const char *l1,
		  const char *f2, const char *l2) {
  for (;(f1 != l1) && (f2 != l2); ++f1, ++f2) {
    while ((*f1 == ' ') && (f1 != l1)) ++f1;
    while ((*f2 == ' ') && (f2 != l2)) ++f2;
    if (*f1 != *f2) return (int)(*f1 - *f2);
  }
  return (l1 - f1) - (l2 - f2);
}

/*
  Check type equivalence in a name list like <name1>|<name2>|...
  Return 0 if not equal, 1 if equal
*/
SWIGRUNTIME int
SWIG_TypeEquiv(const char *nb, const char *tb) {
  int equiv = 0;
  const char* te = tb + strlen(tb);
  const char* ne = nb;
  while (!equiv && *ne) {
    for (nb = ne; *ne; ++ne) {
      if (*ne == '|') break;
    }
    equiv = (SWIG_TypeNameComp(nb, ne, tb, te) == 0) ? 1 : 0;
    if (*ne) ++ne;
  }
  return equiv;
}

/*
  Check type equivalence in a name list like <name1>|<name2>|...
  Return 0 if equal, -1 if nb < tb, 1 if nb > tb
*/
SWIGRUNTIME int
SWIG_TypeCompare(const char *nb, const char *tb) {
  int equiv = 0;
  const char* te = tb + strlen(tb);
  const char* ne = nb;
  while (!equiv && *ne) {
    for (nb = ne; *ne; ++ne) {
      if (*ne == '|') break;
    }
    equiv = (SWIG_TypeNameComp(nb, ne, tb, te) == 0) ? 1 : 0;
    if (*ne) ++ne;
  }
  return equiv;
}


/* think of this as a c++ template<> or a scheme macro */
#define SWIG_TypeCheck_Template(comparison, ty)         \
  if (ty) {                                             \
    swig_cast_info *iter = ty->cast;                    \
    while (iter) {                                      \
      if (comparison) {                                 \
        if (iter == ty->cast) return iter;              \
        /* Move iter to the top of the linked list */   \
        iter->prev->next = iter->next;                  \
        if (iter->next)                                 \
          iter->next->prev = iter->prev;                \
        iter->next = ty->cast;                          \
        iter->prev = 0;                                 \
        if (ty->cast) ty->cast->prev = iter;            \
        ty->cast = iter;                                \
        return iter;                                    \
      }                                                 \
      iter = iter->next;                                \
    }                                                   \
  }                                                     \
  return 0

/*
  Check the typename
*/
SWIGRUNTIME swig_cast_info *
SWIG_TypeCheck(const char *c, swig_type_info *ty) {
  SWIG_TypeCheck_Template(strcmp(iter->type->name, c) == 0, ty);
}

/* Same as previous function, except strcmp is replaced with a pointer comparison */
SWIGRUNTIME swig_cast_info *
SWIG_TypeCheckStruct(swig_type_info *from, swig_type_info *into) {
  SWIG_TypeCheck_Template(iter->type == from, into);
}

/*
  Cast a pointer up an inheritance hierarchy
*/
SWIGRUNTIMEINLINE void *
SWIG_TypeCast(swig_cast_info *ty, void *ptr) {
  return ((!ty) || (!ty->converter)) ? ptr : (*ty->converter)(ptr);
}

/* 
   Dynamic pointer casting. Down an inheritance hierarchy
*/
SWIGRUNTIME swig_type_info *
SWIG_TypeDynamicCast(swig_type_info *ty, void **ptr) {
  swig_type_info *lastty = ty;
  if (!ty || !ty->dcast) return ty;
  while (ty && (ty->dcast)) {
    ty = (*ty->dcast)(ptr);
    if (ty) lastty = ty;
  }
  return lastty;
}

/*
  Return the name associated with this type
*/
SWIGRUNTIMEINLINE const char *
SWIG_TypeName(const swig_type_info *ty) {
  return ty->name;
}

/*
  Return the pretty name associated with this type,
  that is an unmangled type name in a form presentable to the user.
*/
SWIGRUNTIME const char *
SWIG_TypePrettyName(const swig_type_info *type) {
  /* The "str" field contains the equivalent pretty names of the
     type, separated by vertical-bar characters.  We choose
     to print the last name, as it is often (?) the most
     specific. */
  if (!type) return NULL;
  if (type->str != NULL) {
    const char *last_name = type->str;
    const char *s;
    for (s = type->str; *s; s++)
      if (*s == '|') last_name = s+1;
    return last_name;
  }
  else
    return type->name;
}

/* 
   Set the clientdata field for a type
*/
SWIGRUNTIME void
SWIG_TypeClientData(swig_type_info *ti, void *clientdata) {
  swig_cast_info *cast = ti->cast;
  /* if (ti->clientdata == clientdata) return; */
  ti->clientdata = clientdata;
  
  while (cast) {
    if (!cast->converter) {
      swig_type_info *tc = cast->type;
      if (!tc->clientdata) {
	SWIG_TypeClientData(tc, clientdata);
      }
    }    
    cast = cast->next;
  }
}
SWIGRUNTIME void
SWIG_TypeNewClientData(swig_type_info *ti, void *clientdata) {
  SWIG_TypeClientData(ti, clientdata);
  ti->owndata = 1;
}
  
/*
  Search for a swig_type_info structure only by mangled name
  Search is a O(log #types)
  
  We start searching at module start, and finish searching when start == end.  
  Note: if start == end at the beginning of the function, we go all the way around
  the circular list.
*/
SWIGRUNTIME swig_type_info *
SWIG_MangledTypeQueryModule(swig_module_info *start, 
                            swig_module_info *end, 
		            const char *name) {
  swig_module_info *iter = start;
  do {
    if (iter->size) {
      register size_t l = 0;
      register size_t r = iter->size - 1;
      do {
	/* since l+r >= 0, we can (>> 1) instead (/ 2) */
	register size_t i = (l + r) >> 1; 
	const char *iname = iter->types[i]->name;
	if (iname) {
	  register int compare = strcmp(name, iname);
	  if (compare == 0) {	    
	    return iter->types[i];
	  } else if (compare < 0) {
	    if (i) {
	      r = i - 1;
	    } else {
	      break;
	    }
	  } else if (compare > 0) {
	    l = i + 1;
	  }
	} else {
	  break; /* should never happen */
	}
      } while (l <= r);
    }
    iter = iter->next;
  } while (iter != end);
  return 0;
}

/*
  Search for a swig_type_info structure for either a mangled name or a human readable name.
  It first searches the mangled names of the types, which is a O(log #types)
  If a type is not found it then searches the human readable names, which is O(#types).
  
  We start searching at module start, and finish searching when start == end.  
  Note: if start == end at the beginning of the function, we go all the way around
  the circular list.
*/
SWIGRUNTIME swig_type_info *
SWIG_TypeQueryModule(swig_module_info *start, 
                     swig_module_info *end, 
		     const char *name) {
  /* STEP 1: Search the name field using binary search */
  swig_type_info *ret = SWIG_MangledTypeQueryModule(start, end, name);
  if (ret) {
    return ret;
  } else {
    /* STEP 2: If the type hasn't been found, do a complete search
       of the str field (the human readable name) */
    swig_module_info *iter = start;
    do {
      register size_t i = 0;
      for (; i < iter->size; ++i) {
	if (iter->types[i]->str && (SWIG_TypeEquiv(iter->types[i]->str, name)))
	  return iter->types[i];
      }
      iter = iter->next;
    } while (iter != end);
  }
  
  /* neither found a match */
  return 0;
}

/* 
   Pack binary data into a string
*/
SWIGRUNTIME char *
SWIG_PackData(char *c, void *ptr, size_t sz) {
  static const char hex[17] = "0123456789abcdef";
  register const unsigned char *u = (unsigned char *) ptr;
  register const unsigned char *eu =  u + sz;
  for (; u != eu; ++u) {
    register unsigned char uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}

/* 
   Unpack binary data from a string
*/
SWIGRUNTIME const char *
SWIG_UnpackData(const char *c, void *ptr, size_t sz) {
  register unsigned char *u = (unsigned char *) ptr;
  register const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    register char d = *(c++);
    register unsigned char uu;
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    else 
      return (char *) 0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    else 
      return (char *) 0;
    *u = uu;
  }
  return c;
}

/* 
   Pack 'void *' into a string buffer.
*/
SWIGRUNTIME char *
SWIG_PackVoidPtr(char *buff, void *ptr, const char *name, size_t bsz) {
  char *r = buff;
  if ((2*sizeof(void *) + 2) > bsz) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,&ptr,sizeof(void *));
  if (strlen(name) + 1 > (bsz - (r - buff))) return 0;
  strcpy(r,name);
  return buff;
}

SWIGRUNTIME const char *
SWIG_UnpackVoidPtr(const char *c, void **ptr, const char *name) {
  if (*c != '_') {
    if (strcmp(c,"NULL") == 0) {
      *ptr = (void *) 0;
      return name;
    } else {
      return 0;
    }
  }
  return SWIG_UnpackData(++c,ptr,sizeof(void *));
}

SWIGRUNTIME char *
SWIG_PackDataName(char *buff, void *ptr, size_t sz, const char *name, size_t bsz) {
  char *r = buff;
  size_t lname = (name ? strlen(name) : 0);
  if ((2*sz + 2 + lname) > bsz) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  if (lname) {
    strncpy(r,name,lname+1);
  } else {
    *r = 0;
  }
  return buff;
}

SWIGRUNTIME const char *
SWIG_UnpackDataName(const char *c, void *ptr, size_t sz, const char *name) {
  if (*c != '_') {
    if (strcmp(c,"NULL") == 0) {
      memset(ptr,0,sz);
      return name;
    } else {
      return 0;
    }
  }
  return SWIG_UnpackData(++c,ptr,sz);
}

#ifdef __cplusplus
}
#endif

/***********************************************************************
 * pyrun.swg
 *
 *     This file contains the runtime support for Python modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 * Author : David Beazley (beazley@cs.uchicago.edu)
 ************************************************************************/

/* Common SWIG API */

/* for raw pointers */
#define SWIG_Python_ConvertPtr(obj, pptr, type, flags)  SWIG_Python_ConvertPtrAndOwn(obj, pptr, type, flags, 0)
#define SWIG_ConvertPtr(obj, pptr, type, flags)         SWIG_Python_ConvertPtr(obj, pptr, type, flags)
#define SWIG_ConvertPtrAndOwn(obj,pptr,type,flags,own)  SWIG_Python_ConvertPtrAndOwn(obj, pptr, type, flags, own)
#define SWIG_NewPointerObj(ptr, type, flags)            SWIG_Python_NewPointerObj(ptr, type, flags)
#define SWIG_CheckImplicit(ty)                          SWIG_Python_CheckImplicit(ty) 
#define SWIG_AcquirePtr(ptr, src)                       SWIG_Python_AcquirePtr(ptr, src)
#define swig_owntype                                    int

/* for raw packed data */
#define SWIG_ConvertPacked(obj, ptr, sz, ty)            SWIG_Python_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewPackedObj(ptr, sz, type)                SWIG_Python_NewPackedObj(ptr, sz, type)

/* for class or struct pointers */
#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(ptr, type, flags)           SWIG_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_Python_ConvertFunctionPtr(obj, pptr, type)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_Python_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_Python_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_Python_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define SWIG_GetModule(clientdata)                      SWIG_Python_GetModule()
#define SWIG_SetModule(clientdata, pointer)             SWIG_Python_SetModule(pointer)
#define SWIG_NewClientData(obj)                         PySwigClientData_New(obj)

/* A functor is a function object with one single object argument */
#if PY_VERSION_HEX >= 0x02020000
#define SWIG_Python_CallFunctor(functor, obj)	        PyObject_CallFunctionObjArgs(functor, obj, NULL);
#else
#define SWIG_Python_CallFunctor(functor, obj)	        PyObject_CallFunction(functor, "O", obj);
#endif

/* Error manipulation */
#define SWIG_SetErrorObj(type, obj)            		{SWIG_PYTHON_THREAD_BEGIN_BLOCK; PyErr_SetObject(type, obj); SWIG_PYTHON_THREAD_END_BLOCK; }
#define SWIG_SetErrorMsg(type, msg)            		{SWIG_PYTHON_THREAD_BEGIN_BLOCK; PyErr_SetString(type, msg); SWIG_PYTHON_THREAD_END_BLOCK; }
#define SWIG_ErrorType(code)                            SWIG_Python_ErrorType(code)                       
#define SWIG_Error(code, msg)            		SWIG_SetErrorMsg(SWIG_Python_ErrorType(code), msg)
#define SWIG_fail                        		goto fail					   


/*
  Helper for static pointer initialization for both C and C++ code, for example
  static PyObject *SWIG_STATIC_POINTER(MyVar) = NewSomething(...);
*/
#ifdef __cplusplus
#define SWIG_STATIC_POINTER(var)  var
#else
#define SWIG_STATIC_POINTER(var)  var = 0; if (!var) var
#endif

/* -----------------------------------------------------------------------------
 * Pointer declarations
 * ----------------------------------------------------------------------------- */

/* Flags for new pointer objects */
#define SWIG_POINTER_NOSHADOW       (SWIG_POINTER_OWN      << 1)
#define SWIG_POINTER_NEW            (SWIG_POINTER_NOSHADOW | SWIG_POINTER_OWN)

#define SWIG_POINTER_IMPLICIT_CONV  (SWIG_POINTER_DISOWN   << 1)

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0

#ifdef __cplusplus
extern "C" {
#if 0
} /* cc-mode */
#endif
#endif

/*  Safe Py_None and Py_Void accessors */

#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
# ifndef SWIG_PYTHON_NO_SAFE_NONE
#  ifndef SWIG_PYTHON_SAFE_NONE
#   define SWIG_PYTHON_SAFE_NONE
#  endif
# endif
#endif

#ifdef SWIG_PYTHON_SAFE_NONE
SWIGRUNTIMEINLINE PyObject * 
_SWIG_Py_None(void)
{
  PyObject *none = Py_BuildValue("");
  Py_DECREF(none);
  return none;
}
SWIGRUNTIME PyObject * 
SWIG_Py_None(void)
{
  static PyObject *SWIG_STATIC_POINTER(none) = _SWIG_Py_None();
  return none;
}
#  ifdef Py_None
#    undef Py_None
#    define Py_None SWIG_Py_None()
#  endif
#endif

SWIGRUNTIMEINLINE PyObject * 
SWIG_Py_Void(void)
{
  PyObject *none = Py_None;
  Py_INCREF(none);
  return none;
}

/* Append a value to the result obj */

SWIGINTERN PyObject*
SWIG_Python_AppendOutput(PyObject* result, PyObject* obj) {
  if (!result) {
    result = obj;
  } else if (result == Py_None) {
    Py_DECREF(result);
    result = obj;
  } else {
    if (!PyList_Check(result)) {
      PyObject *o2 = result;
      result = PyList_New(1);
      PyList_SetItem(result, 0, o2);
    }
    PyList_Append(result,obj);
    Py_DECREF(obj);
  }
  return result;
}

SWIGINTERN int
SWIG_Python_UnpackTuple(PyObject *args, const char *name, int min, int max, PyObject **objs)
{    
  if (!PyTuple_Check(args)) {
    PyErr_SetString(PyExc_SystemError, "UnpackTuple() argument list is not a tuple");
    return 0;
  } else {
    register int l = PyTuple_GET_SIZE(args);
    if (l < min) {
      PyErr_Format(PyExc_TypeError, "%s expected %s%d arguments, got %d", 
		   name, (min == max ? "" : "at least "), min, l);
      return 0;
    } else if (l > max) {
      PyErr_Format(PyExc_TypeError, "%s expected %s%d arguments, got %d", 
		   name, (min == max ? "" : "at most "), max, l);
      return 0;
    } else {
      register int i;
      for (i = 0; i < l; ++i) {
	objs[i] = PyTuple_GET_ITEM(args, i);
      }
      for (; l < max; ++l) {
	objs[l] = 0;
      }
      return i + 1;
    }    
  }
}

/* PySwigClientData */

typedef struct {
  PyObject *klass;
  PyObject *newraw;
  PyObject *newargs;
  PyObject *destroy;
  int delargs;
  int implicitconv;
} PySwigClientData;

SWIGRUNTIMEINLINE int 
SWIG_Python_CheckImplicit(swig_type_info *ty)
{
  PySwigClientData *data = (PySwigClientData *)ty->clientdata;
  return data ? data->implicitconv : 0;
}


SWIGRUNTIME PySwigClientData * 
PySwigClientData_New(PyObject* obj)
{
  if (!obj) {
    return 0;
  } else {
    PySwigClientData *data = (PySwigClientData *)malloc(sizeof(PySwigClientData));
    /* the klass element */
    data->klass = obj;
    Py_INCREF(obj);
    /* the newraw method and newargs arguments used to create a new raw instance */
    if (PyClass_Check(obj)) {
      data->newraw = 0;
      data->newargs = obj;
      Py_INCREF(obj);
    } else {
#if (PY_VERSION_HEX < 0x02020000)
      data->newraw = 0;
      data->newargs = obj;
      Py_INCREF(obj);
#else
      data->newraw = PyObject_GetAttrString((PyObject*)&PyBaseObject_Type, "__new__");
      Py_INCREF(data->newraw);
      data->newargs = PyTuple_New(1);
      PyTuple_SetItem(data->newargs, 0, obj);
      Py_INCREF(data->newargs);
#endif
    }
    /* the destroy method, aka as the C++ delete method */
    data->destroy = PyObject_GetAttrString(data->klass, "__swig_destroy__");
    if (PyErr_Occurred()) {
      PyErr_Clear();
      data->destroy = 0;
    }
    if (data->destroy) {
      Py_INCREF(data->destroy);
      int flags = PyCFunction_GET_FLAGS(data->destroy);
#ifdef METH_O
      data->delargs = !(flags & (METH_O));
#else
      data->delargs = 0;
#endif
    } else {
      data->delargs = 0;
    }
    data->implicitconv = 0;
    return data;
  }
}

SWIGRUNTIME void 
PySwigClientData_Del(PySwigClientData* data)
{
  Py_XDECREF(data->klass);
  Py_XDECREF(data->newraw);
  Py_XDECREF(data->newargs);
  Py_XDECREF(data->destroy);
  free(data);
}

/* =============== PySwigObject =====================*/

typedef struct {
  PyObject_HEAD
  void *ptr;
  swig_type_info *ty;
  int own;
  PyObject *next;
} PySwigObject;

SWIGRUNTIME PyObject *
PySwigObject_long(PySwigObject *v)
{
  return PyLong_FromVoidPtr(v->ptr);
}

SWIGRUNTIME PyObject *
PySwigObject_format(const char* fmt, PySwigObject *v)
{
  PyObject *res = NULL;
  PyObject *args = PyTuple_New(1);
  if (args) {
    if (PyTuple_SetItem(args, 0, PySwigObject_long(v)) == 0) {
      PyObject *ofmt = PyString_FromString(fmt);
      if (ofmt) {
	res = PyString_Format(ofmt,args);
	Py_DECREF(ofmt);
      }
      Py_DECREF(args);
    }
  }
  return res;
}

SWIGRUNTIME PyObject *
PySwigObject_oct(PySwigObject *v)
{
  return PySwigObject_format("%o",v);
}

SWIGRUNTIME PyObject *
PySwigObject_hex(PySwigObject *v)
{
  return PySwigObject_format("%x",v);
}

SWIGRUNTIME PyObject *
PySwigObject_repr(PySwigObject *v)
{
  const char *name = SWIG_TypePrettyName(v->ty);
  PyObject *hex = PySwigObject_hex(v);    
  PyObject *repr = PyString_FromFormat("<Swig Object of type '%s' at 0x%s>", name, PyString_AsString(hex));
  Py_DECREF(hex);
  if (v->next) {
    PyObject *nrep = PySwigObject_repr((PySwigObject *)v->next);
    PyString_ConcatAndDel(&repr,nrep);
  }
  return repr;  
}

SWIGRUNTIME int
PySwigObject_print(PySwigObject *v, FILE *fp, int SWIGUNUSEDPARM(flags))
{
  PyObject *repr = PySwigObject_repr(v);
  if (repr) {
    fputs(PyString_AsString(repr), fp);
    Py_DECREF(repr);
    return 0; 
  } else {
    return 1; 
  }
}

SWIGRUNTIME PyObject *
PySwigObject_str(PySwigObject *v)
{
  char result[SWIG_BUFFER_SIZE];
  return SWIG_PackVoidPtr(result, v->ptr, v->ty->name, sizeof(result)) ?
    PyString_FromString(result) : 0;
}

SWIGRUNTIME int
PySwigObject_compare(PySwigObject *v, PySwigObject *w)
{
  void *i = v->ptr;
  void *j = w->ptr;
  return (i < j) ? -1 : ((i > j) ? 1 : 0);
}

SWIGRUNTIME PyTypeObject* _PySwigObject_type(void);

SWIGRUNTIME PyTypeObject*
PySwigObject_type(void) {
  static PyTypeObject *SWIG_STATIC_POINTER(type) = _PySwigObject_type();
  return type;
}

SWIGRUNTIMEINLINE int
PySwigObject_Check(PyObject *op) {
  return ((op)->ob_type == PySwigObject_type()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigObject") == 0);
}


SWIGRUNTIME PyObject *
PySwigObject_New(void *ptr, swig_type_info *ty, int own);

SWIGRUNTIME void
PySwigObject_dealloc(PyObject *v)
{
  PySwigObject *sobj = (PySwigObject *) v;
  PyObject *next = sobj->next;
  if (sobj->own) {
    swig_type_info *ty = sobj->ty;
    PySwigClientData *data = ty ? (PySwigClientData *) ty->clientdata : 0;
    PyObject *destroy = data ? data->destroy : 0;
    if (destroy) {
      /* destroy is always a VARARGS method */
      PyObject *res;
      if (data->delargs) {
	/* we need to create a temporal object to carry the destroy operation */
	PyObject *tmp = PySwigObject_New(sobj->ptr, ty, 0);
	res = SWIG_Python_CallFunctor(destroy, tmp);
	Py_DECREF(tmp);
      } else {
	PyCFunction meth = PyCFunction_GET_FUNCTION(destroy);
	PyObject *mself = PyCFunction_GET_SELF(destroy);
	res = ((*meth)(mself, v));
      }
      Py_XDECREF(res);
    } else {
      const char *name = SWIG_TypePrettyName(ty);
#if (PY_VERSION_HEX >= 0x02020000)
      PyObject *wrn = PyString_FromFormat("swig/python detected a memory leak of type '%s'.", name);
      PyErr_Warn(PyExc_RuntimeWarning, PyString_AsString(wrn));
      Py_DECREF(wrn);
#else
      printf("swig/python detected a memory leak of type '%s'.", name);
#endif
    }
  } 
  Py_XDECREF(next);
  PyObject_DEL(v);
}

SWIGRUNTIME PyObject* 
PySwigObject_append(PyObject* v, PyObject* next)
{
  PySwigObject *sobj = (PySwigObject *) v;
#ifndef METH_O
  PyObject *tmp = 0;
  if (!PyArg_ParseTuple(next,(char *)"O:append", &tmp)) return NULL;
  next = tmp;
#endif
  if (!PySwigObject_Check(next)) {
    return NULL;
  }
  sobj->next = next;
  Py_INCREF(next);
  return SWIG_Py_Void();
}

SWIGRUNTIME PyObject* 
#ifdef METH_NOARGS
PySwigObject_next(PyObject* v)
#else
PySwigObject_next(PyObject* v, PyObject *SWIGUNUSEDPARM(args))
#endif
{
  PySwigObject *sobj = (PySwigObject *) v;
  if (sobj->next) {    
    Py_INCREF(sobj->next);
    return sobj->next;
  } else {
    return SWIG_Py_Void();
  }
}

SWIGINTERN PyObject*
#ifdef METH_NOARGS
PySwigObject_disown(PyObject *v)
#else
PySwigObject_disown(PyObject* v, PyObject *SWIGUNUSEDPARM(args))
#endif
{
  PySwigObject *sobj = (PySwigObject *)v;
  sobj->own = 0;
  return SWIG_Py_Void();
}

SWIGINTERN PyObject*
#ifdef METH_NOARGS
PySwigObject_acquire(PyObject *v)
#else
PySwigObject_acquire(PyObject* v, PyObject *SWIGUNUSEDPARM(args))
#endif
{
  PySwigObject *sobj = (PySwigObject *)v;
  sobj->own = SWIG_POINTER_OWN;
  return SWIG_Py_Void();
}

SWIGINTERN PyObject*
PySwigObject_own(PyObject *v, PyObject *args)
{
  PyObject *val = 0;
#if (PY_VERSION_HEX < 0x02020000)
  if (!PyArg_ParseTuple(args,(char *)"O:own",&val))
#else
  if (!PyArg_UnpackTuple(args, (char *)"own", 0, 1, &val)) 
#endif
    {
      return NULL;
    } 
  else
    {
      PySwigObject *sobj = (PySwigObject *)v;
      PyObject *obj = sobj->own ? Py_True : Py_False;
      if (val) {
#ifdef METH_NOARGS
	if (PyObject_IsTrue(val)) {
	  PySwigObject_acquire(v);
	} else {
	  PySwigObject_disown(v);
	}
#else
	if (PyObject_IsTrue(val)) {
	  PySwigObject_acquire(v,args);
	} else {
	  PySwigObject_disown(v,args);
	}
#endif
      } 
      Py_INCREF(obj);
      return obj;
    }
}

SWIGRUNTIME PyTypeObject*
_PySwigObject_type(void) {
  static char swigobject_doc[] = "Swig object carries a C/C++ instance pointer";
  static PyMethodDef
#ifdef METH_O
    swigobject_methods[] = {
      {"disown",  (PyCFunction)PySwigObject_disown,  METH_NOARGS,  "releases ownership of the pointer"},
      {"acquire", (PyCFunction)PySwigObject_acquire, METH_NOARGS,  "aquires ownership of the pointer"},
      {"own",     (PyCFunction)PySwigObject_own,     METH_VARARGS, "returns/sets ownership of the pointer"},
      {"append",  (PyCFunction)PySwigObject_append,  METH_O,       "appends another 'this' object"},
      {"next",    (PyCFunction)PySwigObject_next,    METH_NOARGS,  "returns the next 'this' object"},
      {0, 0, 0, 0}  
    };
#else
    swigobject_methods[] = {
      {"disown",  (PyCFunction)PySwigObject_disown,  METH_VARARGS,  "releases ownership of the pointer"},
      {"acquire", (PyCFunction)PySwigObject_acquire, METH_VARARGS,  "aquires ownership of the pointer"},
      {"own",     (PyCFunction)PySwigObject_own,     METH_VARARGS, "returns/sets ownership of the pointer"},
      {"append",  (PyCFunction)PySwigObject_append,  METH_VARARGS,       "appends another 'this' object"},
      {"next",    (PyCFunction)PySwigObject_next,    METH_VARARGS,  "returns the next 'this' object"},
      {0, 0, 0, 0}  
    };
#endif
  
  static PyNumberMethods PySwigObject_as_number = {
    (binaryfunc)0, /*nb_add*/
    (binaryfunc)0, /*nb_subtract*/
    (binaryfunc)0, /*nb_multiply*/
    (binaryfunc)0, /*nb_divide*/
    (binaryfunc)0, /*nb_remainder*/
    (binaryfunc)0, /*nb_divmod*/
    (ternaryfunc)0,/*nb_power*/
    (unaryfunc)0,  /*nb_negative*/
    (unaryfunc)0,  /*nb_positive*/
    (unaryfunc)0,  /*nb_absolute*/
    (inquiry)0,    /*nb_nonzero*/
    0,		   /*nb_invert*/
    0,		   /*nb_lshift*/
    0,		   /*nb_rshift*/
    0,		   /*nb_and*/
    0,		   /*nb_xor*/
    0,		   /*nb_or*/
    (coercion)0,   /*nb_coerce*/
    (unaryfunc)PySwigObject_long, /*nb_int*/
    (unaryfunc)PySwigObject_long, /*nb_long*/
    (unaryfunc)0,                 /*nb_float*/
    (unaryfunc)PySwigObject_oct,  /*nb_oct*/
    (unaryfunc)PySwigObject_hex,  /*nb_hex*/
#if PY_VERSION_HEX >= 0x02020000
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /* nb_inplace_add -> nb_inplace_true_divide */ 
#elif PY_VERSION_HEX >= 0x02000000
    0,0,0,0,0,0,0,0,0,0,0 /* nb_inplace_add -> nb_inplace_or */
#endif
  };

  static PyTypeObject pyswigobject_type;  
  static int type_init = 0;
  if (!type_init) {
    const PyTypeObject tmp
      = {
	PyObject_HEAD_INIT(NULL)
	0,				    /* ob_size */
	(char *)"PySwigObject",		    /* tp_name */
	sizeof(PySwigObject),		    /* tp_basicsize */
	0,			            /* tp_itemsize */
	(destructor)PySwigObject_dealloc,   /* tp_dealloc */
	(printfunc)PySwigObject_print,	    /* tp_print */   
	(getattrfunc)0,			    /* tp_getattr */ 
	(setattrfunc)0,			    /* tp_setattr */ 
	(cmpfunc)PySwigObject_compare,	    /* tp_compare */ 
	(reprfunc)PySwigObject_repr,	    /* tp_repr */    
	&PySwigObject_as_number,	    /* tp_as_number */
	0,				    /* tp_as_sequence */
	0,				    /* tp_as_mapping */
	(hashfunc)0,			    /* tp_hash */
	(ternaryfunc)0,			    /* tp_call */
	(reprfunc)PySwigObject_str,	    /* tp_str */
	PyObject_GenericGetAttr,	    /* tp_getattro */
	0,				    /* tp_setattro */
	0,		                    /* tp_as_buffer */
	Py_TPFLAGS_DEFAULT,	            /* tp_flags */
	swigobject_doc, 	            /* tp_doc */        
	0,                                  /* tp_traverse */
	0,                                  /* tp_clear */
	0,                                  /* tp_richcompare */
	0,                                  /* tp_weaklistoffset */
#if PY_VERSION_HEX >= 0x02020000
	0,                                  /* tp_iter */
	0,                                  /* tp_iternext */
	swigobject_methods,		    /* tp_methods */ 
	0,			            /* tp_members */
	0,				    /* tp_getset */	    	
	0,			            /* tp_base */	        
	0,				    /* tp_dict */	    	
	0,				    /* tp_descr_get */  	
	0,				    /* tp_descr_set */  	
	0,				    /* tp_dictoffset */ 	
	0,				    /* tp_init */	    	
	0,				    /* tp_alloc */	    	
	0,			            /* tp_new */	    	
	PyObject_Del,	                    /* tp_free */	   
        0,                                  /* tp_is_gc */  
	0,				    /* tp_bases */   
	0,				    /* tp_mro */
	0,				    /* tp_cache */   
 	0,				    /* tp_subclasses */
	0,				    /* tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
	0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
	0,0,0,0                             /* tp_alloc -> tp_next */
#endif
      };
    pyswigobject_type = tmp;
    pyswigobject_type.ob_type = &PyType_Type;
    type_init = 1;
  }
  return &pyswigobject_type;
}

SWIGRUNTIME PyObject *
PySwigObject_New(void *ptr, swig_type_info *ty, int own)
{
  PySwigObject *sobj = PyObject_NEW(PySwigObject, PySwigObject_type());
  if (sobj) {
    sobj->ptr  = ptr;
    sobj->ty   = ty;
    sobj->own  = own;
    sobj->next = 0;
  }
  return (PyObject *)sobj;
}

/* -----------------------------------------------------------------------------
 * Implements a simple Swig Packed type, and use it instead of string
 * ----------------------------------------------------------------------------- */

typedef struct {
  PyObject_HEAD
  void *pack;
  swig_type_info *ty;
  size_t size;
} PySwigPacked;

SWIGRUNTIME int
PySwigPacked_print(PySwigPacked *v, FILE *fp, int SWIGUNUSEDPARM(flags))
{
  char result[SWIG_BUFFER_SIZE];
  fputs("<Swig Packed ", fp); 
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    fputs("at ", fp); 
    fputs(result, fp); 
  }
  fputs(v->ty->name,fp); 
  fputs(">", fp);
  return 0; 
}
  
SWIGRUNTIME PyObject *
PySwigPacked_repr(PySwigPacked *v)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    return PyString_FromFormat("<Swig Packed at %s%s>", result, v->ty->name);
  } else {
    return PyString_FromFormat("<Swig Packed %s>", v->ty->name);
  }  
}

SWIGRUNTIME PyObject *
PySwigPacked_str(PySwigPacked *v)
{
  char result[SWIG_BUFFER_SIZE];
  if (SWIG_PackDataName(result, v->pack, v->size, 0, sizeof(result))){
    return PyString_FromFormat("%s%s", result, v->ty->name);
  } else {
    return PyString_FromString(v->ty->name);
  }  
}

SWIGRUNTIME int
PySwigPacked_compare(PySwigPacked *v, PySwigPacked *w)
{
  size_t i = v->size;
  size_t j = w->size;
  int s = (i < j) ? -1 : ((i > j) ? 1 : 0);
  return s ? s : strncmp((char *)v->pack, (char *)w->pack, 2*v->size);
}

SWIGRUNTIME PyTypeObject* _PySwigPacked_type(void);

SWIGRUNTIME PyTypeObject*
PySwigPacked_type(void) {
  static PyTypeObject *SWIG_STATIC_POINTER(type) = _PySwigPacked_type();
  return type;
}

SWIGRUNTIMEINLINE int
PySwigPacked_Check(PyObject *op) {
  return ((op)->ob_type == _PySwigPacked_type()) 
    || (strcmp((op)->ob_type->tp_name,"PySwigPacked") == 0);
}

SWIGRUNTIME void
PySwigPacked_dealloc(PyObject *v)
{
  if (PySwigPacked_Check(v)) {
    PySwigPacked *sobj = (PySwigPacked *) v;
    free(sobj->pack);
  }
  PyObject_DEL(v);
}

SWIGRUNTIME PyTypeObject*
_PySwigPacked_type(void) {
  static char swigpacked_doc[] = "Swig object carries a C/C++ instance pointer";
  static PyTypeObject pyswigpacked_type;
  static int type_init = 0;  
  if (!type_init) {
    const PyTypeObject tmp
      = {
	PyObject_HEAD_INIT(NULL)
	0,				    /* ob_size */	
	(char *)"PySwigPacked",		    /* tp_name */	
	sizeof(PySwigPacked),		    /* tp_basicsize */	
	0,				    /* tp_itemsize */	
	(destructor)PySwigPacked_dealloc,   /* tp_dealloc */	
	(printfunc)PySwigPacked_print,	    /* tp_print */   	
	(getattrfunc)0,			    /* tp_getattr */ 	
	(setattrfunc)0,			    /* tp_setattr */ 	
	(cmpfunc)PySwigPacked_compare,	    /* tp_compare */ 	
	(reprfunc)PySwigPacked_repr,	    /* tp_repr */    	
	0,	                            /* tp_as_number */	
	0,				    /* tp_as_sequence */
	0,				    /* tp_as_mapping */	
	(hashfunc)0,			    /* tp_hash */	
	(ternaryfunc)0,			    /* tp_call */	
	(reprfunc)PySwigPacked_str,	    /* tp_str */	
	PyObject_GenericGetAttr,            /* tp_getattro */
	0,				    /* tp_setattro */
	0,		                    /* tp_as_buffer */
	Py_TPFLAGS_DEFAULT,	            /* tp_flags */
	swigpacked_doc, 	            /* tp_doc */
	0,                                  /* tp_traverse */
	0,                                  /* tp_clear */
	0,                                  /* tp_richcompare */
	0,                                  /* tp_weaklistoffset */
#if PY_VERSION_HEX >= 0x02020000
	0,                                  /* tp_iter */
	0,                                  /* tp_iternext */
	0,		                    /* tp_methods */ 
	0,			            /* tp_members */
	0,				    /* tp_getset */	    	
	0,			            /* tp_base */	        
	0,				    /* tp_dict */	    	
	0,				    /* tp_descr_get */  	
	0,				    /* tp_descr_set */  	
	0,				    /* tp_dictoffset */ 	
	0,				    /* tp_init */	    	
	0,				    /* tp_alloc */	    	
	0,			            /* tp_new */	    	
	PyObject_Del, 	                    /* tp_free */	   
        0,                                  /* tp_is_gc */  
	0,				    /* tp_bases */   
	0,				    /* tp_mro */
	0,				    /* tp_cache */   
 	0,				    /* tp_subclasses */
	0,				    /* tp_weaklist */
#endif
#if PY_VERSION_HEX >= 0x02030000
	0,                                  /* tp_del */
#endif
#ifdef COUNT_ALLOCS
	0,0,0,0                             /* tp_alloc -> tp_next */
#endif
      };
    pyswigpacked_type = tmp;
    pyswigpacked_type.ob_type = &PyType_Type;
    type_init = 1;
  }
  return &pyswigpacked_type;
}

SWIGRUNTIME PyObject *
PySwigPacked_New(void *ptr, size_t size, swig_type_info *ty)
{
  PySwigPacked *sobj = PyObject_NEW(PySwigPacked, PySwigPacked_type());
  if (sobj) {
    void *pack = malloc(size);
    if (pack) {
      memcpy(pack, ptr, size);
      sobj->pack = pack;
      sobj->ty   = ty;
      sobj->size = size;
    } else {
      PyObject_DEL((PyObject *) sobj);
      sobj = 0;
    }
  }
  return (PyObject *) sobj;
}

SWIGRUNTIME swig_type_info *
PySwigPacked_UnpackData(PyObject *obj, void *ptr, size_t size)
{
  if (PySwigPacked_Check(obj)) {
    PySwigPacked *sobj = (PySwigPacked *)obj;
    if (sobj->size != size) return 0;
    memcpy(ptr, sobj->pack, size);
    return sobj->ty;
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

SWIGRUNTIME PyObject *
_SWIG_This(void)
{
  static PyObject *_this = 0;
  if (!_this) {
    _this = PyString_FromString("this");
  }
  return _this;
}

SWIGRUNTIME PyObject *
SWIG_This(void)
{
  static PyObject *SWIG_STATIC_POINTER(swig_this) = _SWIG_This();
  return swig_this;
}

/* #define SWIG_PYTHON_SLOW_GETSET_THIS */

SWIGRUNTIME PySwigObject *
SWIG_Python_GetSwigThis(PyObject *pyobj) 
{
  if (PySwigObject_Check(pyobj)) {
    return (PySwigObject *) pyobj;
  } else {
    PyObject *obj = 0;
#if (!defined(SWIG_PYTHON_SLOW_GETSET_THIS) && !(PY_VERSION_HEX < 0x02020000))
    if (PyInstance_Check(pyobj)) {
      obj = _PyInstance_Lookup(pyobj, SWIG_This());
    } else {
      PyObject **dictptr = _PyObject_GetDictPtr(pyobj);
      if (dictptr != NULL) {
	PyObject *dict = *dictptr;
	obj = dict ? PyDict_GetItem(dict, SWIG_This()) : 0;
      }      
#ifdef PyWeakref_CheckProxy
      else if (PyWeakref_CheckProxy(pyobj)) {
	PyObject *wobj = PyWeakref_GET_OBJECT(pyobj);
	return wobj ? SWIG_Python_GetSwigThis(wobj) : 0;
      }
#endif
      if (!obj) {
	obj = PyObject_GetAttr(pyobj,SWIG_This());
	if (obj) {
	  Py_DECREF(obj);
	} else {
	  if (PyErr_Occurred()) PyErr_Clear();
	  return 0;
	}
      }
    }
#else
    obj = PyObject_GetAttr(pyobj,SWIG_This());
    if (obj) {
      Py_DECREF(obj);
    } else {
      if (PyErr_Occurred()) PyErr_Clear();
      return 0;
    }
#endif
    return (PySwigObject *)obj;
  }
}


/* Acquire a pointer value */

SWIGRUNTIME int
SWIG_Python_AcquirePtr(PyObject *obj, int own) {
  if (own) {
    PySwigObject *sobj = SWIG_Python_GetSwigThis(obj);
    if (sobj) {
      int oldown = sobj->own;
      sobj->own = own;
      return oldown;
    }
  }
  return 0;
}

/* Convert a pointer value */

SWIGRUNTIME int
SWIG_Python_ConvertPtrAndOwn(PyObject *obj, void **ptr, swig_type_info *ty, int flags, int *own) {
  if (!obj) return SWIG_ERROR;
  if (obj == Py_None) {
    if (ptr) *ptr = 0;
    return SWIG_OK;
  } else {
    PySwigObject *sobj = SWIG_Python_GetSwigThis(obj);
    while (sobj) {
      void *vptr = sobj->ptr;
      if (ty) {
	swig_type_info *to = sobj->ty;
	if (to == ty) {
	  /* no type cast needed */
	  if (ptr) *ptr = vptr;
	  break;
	} else {
	  swig_cast_info *tc = SWIG_TypeCheck(to->name,ty);
	  if (!tc) {
	    sobj = (PySwigObject *)sobj->next;
	  } else {
	    if (ptr) *ptr = SWIG_TypeCast(tc,vptr);
	    break;
	  }
	}
      } else {
	if (ptr) *ptr = vptr;
	break;
      }
    }
    if (sobj) {
      if (own) *own = sobj->own;
      if (flags & SWIG_POINTER_DISOWN) {
	sobj->own = 0;
      }
      return SWIG_OK;
    } else {
      int res = SWIG_ERROR;
      if (flags & SWIG_POINTER_IMPLICIT_CONV) {
	PySwigClientData *data = ty ? (PySwigClientData *) ty->clientdata : 0;
	if (data && !data->implicitconv) {
	  PyObject *klass = data->klass;
	  if (klass) {
	    PyObject *impconv;
	    data->implicitconv = 1; /* avoid recursion and call 'explicit' constructors*/
	    impconv = SWIG_Python_CallFunctor(klass, obj);
	    data->implicitconv = 0;
	    if (PyErr_Occurred()) {
	      PyErr_Clear();
	      impconv = 0;
	    }
	    if (impconv) {
	      PySwigObject *sobj = SWIG_Python_GetSwigThis(impconv);
	      if (sobj) {
		void *vptr;
		res = SWIG_Python_ConvertPtrAndOwn((PyObject*)sobj, &vptr, ty, 0, 0);
		if (SWIG_IsOK(res)) {
		  if (ptr) {
		    *ptr = vptr;
		    /* transfer the ownership to 'ptr' */
		    sobj->own = 0;
		    res = SWIG_AddNewMask(SWIG_AddCast(res));		    
		  } else {
		    res = SWIG_AddCast(res);		    
		  }
		}
	      }
	      Py_DECREF(impconv);
	    }
	  }
	}
      }
      return res;
    }
  }
}

/* Convert a function ptr value */

SWIGRUNTIME int
SWIG_Python_ConvertFunctionPtr(PyObject *obj, void **ptr, swig_type_info *ty) {
  if (!PyCFunction_Check(obj)) {
    return SWIG_ConvertPtr(obj, ptr, ty, 0);
  } else {
    void *vptr = 0;
    
    /* here we get the method pointer for callbacks */
    char *doc = (((PyCFunctionObject *)obj) -> m_ml -> ml_doc);
    const char *desc = doc ? strstr(doc, "swig_ptr: ") : 0;
    if (desc) {
      desc = ty ? SWIG_UnpackVoidPtr(desc + 10, &vptr, ty->name) : 0;
      if (!desc) return SWIG_ERROR;
    }
    if (ty) {
      swig_cast_info *tc = SWIG_TypeCheck(desc,ty);
      if (!tc) return SWIG_ERROR;
      *ptr = SWIG_TypeCast(tc,vptr);
    } else {
      *ptr = vptr;
    }
    return SWIG_OK;
  }
}

/* Convert a packed value value */

SWIGRUNTIME int
SWIG_Python_ConvertPacked(PyObject *obj, void *ptr, size_t sz, swig_type_info *ty) {
  swig_type_info *to = PySwigPacked_UnpackData(obj, ptr, sz);
  if (!to) return SWIG_ERROR;
  if (ty) {
    if (to != ty) {
      /* check type cast? */
      swig_cast_info *tc = SWIG_TypeCheck(to->name,ty);
      if (!tc) return SWIG_ERROR;
    }
  }
  return SWIG_OK;
}  

/* -----------------------------------------------------------------------------
 * Create a new pointer object
 * ----------------------------------------------------------------------------- */

/*
  Create a new instance object, whitout calling __init__, and set the
  'this' attribute.
*/

SWIGRUNTIME PyObject* 
SWIG_Python_NewShadowInstance(PySwigClientData *data, PyObject *swig_this)
{
#if (PY_VERSION_HEX >= 0x02020000)
  PyObject *inst = 0;
  PyObject *newraw = data->newraw;
  if (newraw) {
    inst = PyObject_Call(newraw, data->newargs, NULL);
    if (inst) {
#if !defined(SWIG_PYTHON_SLOW_GETSET_THIS)
      PyObject **dictptr = _PyObject_GetDictPtr(inst);
      if (dictptr != NULL) {
	PyObject *dict = *dictptr;
	if (dict == NULL) {
	  dict = PyDict_New();
	  *dictptr = dict;
	  PyDict_SetItem(dict, SWIG_This(), swig_this);
	}
      }
#else
      PyObject *key = SWIG_This();
      PyObject_SetAttr(inst, key, swig_this);
#endif
    }
  } else {
    PyObject *dict = PyDict_New();
    PyDict_SetItem(dict, SWIG_This(), swig_this);
    inst = PyInstance_NewRaw(data->newargs, dict);
    Py_DECREF(dict);
  }
  return inst;
#else
  PyInstanceObject *inst = PyObject_NEW(PyInstanceObject, &PyInstance_Type);
  if (inst == NULL) {
    return NULL;
  }
  inst->in_class = (PyClassObject *)data->newargs;
  Py_INCREF(inst->in_class);
  inst->in_dict = PyDict_New();
  if (inst->in_dict == NULL) {
    Py_DECREF(inst);
    return NULL;
  }
  PyDict_SetItem(inst->in_dict, SWIG_This(), swig_this);
  return (PyObject *) inst;
#endif
}

/* Create a new pointer object */

SWIGRUNTIME PyObject *
SWIG_Python_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  if (!ptr) {
    return SWIG_Py_Void();
  } else {
    int own = (flags & SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;
    PyObject *robj = PySwigObject_New(ptr, type, own);
    PySwigClientData *clientdata = type ? (PySwigClientData *)(type->clientdata) : 0;
    if (clientdata && !(flags & SWIG_POINTER_NOSHADOW)) {
      PyObject *inst = SWIG_Python_NewShadowInstance(clientdata, robj);
      if (inst) {
	Py_DECREF(robj);
	robj = inst;
      }
    }
    return robj;
  }
}

/* Create a new packed object */

SWIGRUNTIMEINLINE PyObject *
SWIG_Python_NewPackedObj(void *ptr, size_t sz, swig_type_info *type) {
  return ptr ? PySwigPacked_New((void *) ptr, sz, type) : SWIG_Py_Void();
}

/* -----------------------------------------------------------------------------*
 *  Get type list 
 * -----------------------------------------------------------------------------*/

#ifdef SWIG_LINK_RUNTIME
void *SWIG_ReturnGlobalTypeList(void *);
#endif

SWIGRUNTIME swig_module_info *
SWIG_Python_GetModule(void) {
  static void *type_pointer = (void *)0;
  /* first check if module already created */
  if (!type_pointer) {
#ifdef SWIG_LINK_RUNTIME
    type_pointer = SWIG_ReturnGlobalTypeList((void *)0);
#else
    type_pointer = PyCObject_Import((char*)"swig_runtime_data" SWIG_RUNTIME_VERSION,
				    (char*)"type_pointer" SWIG_TYPE_TABLE_NAME);
    if (PyErr_Occurred()) {
      PyErr_Clear();
      type_pointer = (void *)0;
    }
#endif
  }
  return (swig_module_info *) type_pointer;
}

#if PY_MAJOR_VERSION < 2
/* PyModule_AddObject function was introduced in Python 2.0.  The following function
   is copied out of Python/modsupport.c in python version 2.3.4 */
SWIGINTERN int
PyModule_AddObject(PyObject *m, char *name, PyObject *o)
{
  PyObject *dict;
  if (!PyModule_Check(m)) {
    PyErr_SetString(PyExc_TypeError,
		    "PyModule_AddObject() needs module as first arg");
    return SWIG_ERROR;
  }
  if (!o) {
    PyErr_SetString(PyExc_TypeError,
		    "PyModule_AddObject() needs non-NULL value");
    return SWIG_ERROR;
  }
  
  dict = PyModule_GetDict(m);
  if (dict == NULL) {
    /* Internal error -- modules must have a dict! */
    PyErr_Format(PyExc_SystemError, "module '%s' has no __dict__",
		 PyModule_GetName(m));
    return SWIG_ERROR;
  }
  if (PyDict_SetItemString(dict, name, o))
    return SWIG_ERROR;
  Py_DECREF(o);
  return SWIG_OK;
}
#endif

SWIGRUNTIME void
SWIG_Python_DestroyModule(void *vptr)
{
  swig_module_info *swig_module = (swig_module_info *) vptr;
  swig_type_info **types = swig_module->types;
  size_t i;
  for (i =0; i < swig_module->size; ++i) {
    swig_type_info *ty = types[i];
    if (ty->owndata) {
      PySwigClientData *data = (PySwigClientData *) ty->clientdata;
      if (data) PySwigClientData_Del(data);
      ty->clientdata = 0;
    }
  }
  Py_DECREF(SWIG_This());
}

SWIGRUNTIME void
SWIG_Python_SetModule(swig_module_info *swig_module) {
  static PyMethodDef swig_empty_runtime_method_table[] = { {NULL, NULL, 0, NULL} };/* Sentinel */

  PyObject *module = Py_InitModule((char*)"swig_runtime_data" SWIG_RUNTIME_VERSION,
				   swig_empty_runtime_method_table);
  PyObject *pointer = PyCObject_FromVoidPtr((void *) swig_module, SWIG_Python_DestroyModule);
  if (pointer && module) {
    PyModule_AddObject(module, (char*)"type_pointer" SWIG_TYPE_TABLE_NAME, pointer);
  } else {
    Py_XDECREF(pointer);
  }
}

#ifdef __cplusplus
#if 0
{ /* cc-mode */
#endif
}
#endif

/* -----------------------------------------------------------------------------*
   Standard SWIG API for use inside user code.
 
   Don't include this file directly, run the command
   swig -python -external-runtime
   Also, read the Modules chapter of the SWIG Manual.
 
 * -----------------------------------------------------------------------------*/

#ifdef SWIG_MODULE_CLIENTDATA_TYPE

SWIGRUNTIMEINLINE swig_type_info *
SWIG_TypeQuery(SWIG_MODULE_CLIENTDATA_TYPE clientdata, const char *name) {
  swig_module_info *module = SWIG_GetModule(clientdata);
  return SWIG_TypeQueryModule(module, module, name);
}

SWIGRUNTIMEINLINE swig_type_info *
SWIG_MangledTypeQuery(SWIG_MODULE_CLIENTDATA_TYPE clientdata, const char *name) {
  swig_module_info *module = SWIG_GetModule(clientdata);
  return SWIG_MangledTypeQueryModule(module, module, name);
}

#else

SWIGRUNTIMEINLINE swig_type_info *
SWIG_TypeQuery(const char *name) {
  swig_module_info *module = SWIG_GetModule(NULL);
  return SWIG_TypeQueryModule(module, module, name);
}

SWIGRUNTIMEINLINE swig_type_info *
SWIG_MangledTypeQuery(const char *name) {
  swig_module_info *module = SWIG_GetModule(NULL);
  return SWIG_MangledTypeQueryModule(module, module, name);
}

#endif

"""
