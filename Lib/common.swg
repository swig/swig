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

#if defined(_WIN32) || defined(__WIN32__)
#       if defined(_MSC_VER)
#               if defined(STATIC_LINKED)
#                       define SWIGEXPORT(a) a
#               else
#                       define SWIGEXPORT(a) __declspec(dllexport) a
#               endif
#       else
#               if defined(__BORLANDC__)
#                       define SWIGEXPORT(a) a _export
#               else
#                       define SWIGEXPORT(a) a
#       endif
#endif
#else
#       define SWIGEXPORT(a) a
#endif

#ifdef SWIG_GLOBAL
#define SWIGSTATICRUNTIME(a) SWIGEXPORT(a)
#else
#define SWIGSTATICRUNTIME(a) static a
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _swig_type_info {
  char  *name;                 
  void *(*converter)(void *);
  char  *str;
  struct _swig_type_info  *next;
  struct _swig_type_info  *prev;
} _swig_type_info;

#ifdef SWIG_NOINCLUDE
SWIGEXPORT(_swig_type_info *) SWIG_TypeRegister(_swig_type_info *);
SWIGEXPORT(_swig_type_info *) SWIG_TypeCheck(char *c, _swig_type_info *);
SWIGEXPORT(void *) SWIG_TypeCast(_swig_type_info *, void *);
#else

static _swig_type_info *swig_types = 0;

/* Register a type mapping with the type-checking */
SWIGSTATICRUNTIME(_swig_type_info *)
SWIG_TypeRegister(_swig_type_info *ti)
{
  _swig_type_info *tc, *head, *ret, *next;
  /* Check to see if this type has already been registered */
  tc = swig_types;
  while (tc) {
    if (strcmp(tc->name, ti->name) == 0) {
      /* Already exists in the table.  Just add additional types to the list */
      head = tc;
      next = tc->next;
      goto l1;
    }
    tc = tc->prev;
  }
  head = ti;
  next = 0;

  /* Place in list */
  ti->prev = swig_types;
  swig_types = ti;

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
  head->next = next;
  return ret;
}

/* Check the typename */
SWIGSTATICRUNTIME(_swig_type_info *) 
SWIG_TypeCheck(char *c, _swig_type_info *ty)
{
  _swig_type_info *s;
  if (!ty) return 0;        /* Void pointer */
  s = ty->next;             /* First element always just a name */
  while (s) {
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
      return s;
    }
    s = s->next;
  }
  return 0;
}

/* Cast a pointer (needed for C++ inheritance */
SWIGSTATICRUNTIME(void *) 
SWIG_TypeCast(_swig_type_info *ty, void *ptr) 
{
  if ((!ty) || (!ty->converter)) return ptr;
  return (*ty->converter)(ptr);
}
#endif

#ifdef __cplusplus
}
#endif



