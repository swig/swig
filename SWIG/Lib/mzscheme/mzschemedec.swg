/* -*-c-*-
 * -----------------------------------------------------------------------
 * swig_lib/mzscheme/mzschemedec.swg
 * Copyright (C) 2000, 2001 Matthias Koeppe
 *
 * MzScheme runtime code -- declarations
 * ----------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <escheme.h>

#if defined(SWIG_NOINCLUDE)
#	define SWIGSTATIC
#elif defined(SWIG_GLOBAL)
#	define SWIGSTATIC
#else
#	define SWIGSTATIC static
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define MAXVALUES 6

static Scheme_Object *
swig_make_boolean(int b)
{
  if (b) return scheme_true;
  else return scheme_false;
}

static Scheme_Object *
swig_package_values(int num, Scheme_Object **values);

  
typedef struct SwigPtrType SwigPtrType;
typedef struct swig_type_info *(*swig_dycast_func)(void **);

typedef struct swig_type_info {
  const char  *name;
  void *(*converter)(void *);
  const char  *str;
  void        *clientdata;
  SwigPtrType *ptrtype;
  swig_dycast_func        dcast;
} swig_type_info;

SWIGSTATIC SwigPtrType *
SWIG_RegisterType (const char *type, const char *prettyname);

SWIGSTATIC void
SWIG_RegisterMapping (const char *origtype, const char *newtype, void *(*cast)(void *));

/* Dynamic pointer casting. Down an inheritance hierarchy */
SWIGSTATIC swig_type_info * 
SWIG_TypeDynamicCast(swig_type_info *ty, void **ptr);
  
SWIGSTATIC Scheme_Object *
SWIG_MakePtr(void *c_pointer, swig_type_info *type);
  
SWIGSTATIC int
SWIG_GetPtr(Scheme_Object *s, void **result, swig_type_info *type);

SWIGSTATIC void *
SWIG_MustGetPtr_ (Scheme_Object *s,  swig_type_info *type,
		 int argnum, const char *func_name,
		 int argc, Scheme_Object **argv);
  
#define SWIG_MustGetPtr(s, type, argnum) \
  SWIG_MustGetPtr_(s, type, argnum, FUNC_NAME, argc, argv)

SWIGSTATIC
void SWIG_RegisterTypes(swig_type_info **table,
			swig_type_info **init);

#ifdef __cplusplus
}
#endif

/* mzschemedec.swg ends here */
