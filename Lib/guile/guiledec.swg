/* -*- c -*-
 * -----------------------------------------------------------------------
 * swig_lib/guile/guiledec.swg
 * Copyright (C) 2000 Matthias Koeppe
 *
 * Guile configuration file -- declarations
 * ----------------------------------------------------------------------- */

#define SWIGGUILE
#include "guile/gh.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(SWIG_NOINCLUDE)
#	define SWIGSTATIC
#elif defined(SWIG_GLOBAL)
#	define SWIGSTATIC
#else
#	define SWIGSTATIC static
#endif

#define GH_NOT_PASSED    SCM_UNDEFINED
#define GH_UNSPECIFIED   SCM_UNSPECIFIED

#define SWIG_APPEND_VALUE(object)						\
    if (gswig_result == GH_UNSPECIFIED)						\
        gswig_result = object;							\
    else {									\
        if (!gswig_list_p) {							\
	    gswig_list_p = 1;							\
	    gswig_result = gh_list(gswig_result, object, GH_NOT_PASSED);	\
        }									\
        else									\
            gswig_result = gh_append2(gswig_result,				\
                                      gh_list(object, GH_NOT_PASSED));		\
    }

#define GUILE_APPEND_RESULT SWIG_APPEND_VALUE
  
/* scm_values was implemented on C level in 1.4.1, and the prototype
   is not included in libguile.h, so play safe and lookup `values'... */
#define GUILE_MAYBE_VALUES						\
    if (gswig_list_p)							\
        gswig_result = gh_apply(gh_lookup("values"), gswig_result);
    
#define GUILE_MAYBE_VECTOR				\
    if (gswig_list_p)					\
        gswig_result = gh_list_to_vector(gswig_result);

static char *
SWIG_scm2str (SCM s)
{
  return gh_scm2newstr (s, NULL);
}

#define GSWIG_scm2str SWIG_scm2str

/* SCM_CHAR and SCM_CHARP were introduced in Guile 1.4; the following is for
   1.3.4 compatibility. */
#ifndef SCM_CHAR
#  define SCM_CHAR SCM_ICHR
#endif
#ifndef SCM_CHARP
#  define SCM_CHARP SCM_ICHRP
#endif

/* This function replaces gh_scm2char, which is broken in Guile 1.4 */
static char
GSWIG_scm2char (SCM s)
{
  if (SCM_CHARP(s)) return SCM_CHAR(s);
  scm_wrong_type_arg(NULL, 0, s);
}
#define gh_scm2char GSWIG_scm2char

/* More 1.3.4 compatibility */
#ifndef SCM_INPUT_PORT_P
#  define SCM_INPUT_PORT_P SCM_INPORTP
#  define SCM_OUTPUT_PORT_P SCM_OUTPORTP
#endif

/* Type system */

typedef void *(*swig_converter_func)(void *);
typedef struct swig_type_info *(*swig_dycast_func)(void **);

typedef struct SwigPtrType SwigPtrType;

typedef struct swig_type_info {
  const char  *name;
  swig_converter_func converter;
  const char  *str;
  void        *clientdata;
  size_t tag;
  swig_dycast_func        dcast;
} swig_type_info;

SWIGSTATIC void
SWIG_Guile_RegisterTypes (swig_type_info **table,
			  swig_type_info **init);

/* Register a new type-mapping with the type-checker.  origtype is the
   original datatype and newtype is an equivalent type.  cast is optional
   pointer to a function to cast pointer values between types (this is
   typically used to cast pointers from derived classes to base classes in
   C++).  */

SWIGSTATIC void
SWIG_RegisterMapping (const char *origtype, const char *newtype,
                      swig_converter_func cast);


/* Dynamic pointer casting. Down an inheritance hierarchy */
SWIGSTATIC swig_type_info * 
SWIG_TypeDynamicCast(swig_type_info *ty, void **ptr);

/* Register SWIG smobs with Guile.  */
SWIGSTATIC void
SWIG_Guile_Init();

/* Initialization function for this SWIG module; actually renamed by a
   #define */
/* extern void SWIG_init(); */

/* Get a pointer value from a smob.  If there is a type-mismatch,
   return nonzero; on success, return 0.  */
SWIGSTATIC int
SWIG_Guile_GetPtr (SCM s, void **result, swig_type_info *type);

/* Get a pointer value from a smob.  If there is a type-mismatch,
   signal a wrong-type-arg error for the given argument number. */
SWIGSTATIC void *
SWIG_Guile_MustGetPtr (SCM s, swig_type_info *type,
		       int argnum, const char *func_name);

/* Make a smob from a pointer and typeinfo.  */
SWIGSTATIC SCM
SWIG_Guile_MakePtr (void *ptr, swig_type_info *type);

/* Get arguments from an argument list */
SWIGSTATIC int
SWIG_Guile_GetArgs (SCM *dest, SCM rest,
		    int reqargs, int optargs,
		    const char *procname);

typedef SCM (*swig_guile_proc)();

#ifdef __cplusplus
}
#endif

/* guiledec.swg ends here */
