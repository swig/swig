/* -*- c -*-
 *  -----------------------------------------------------------------------
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

#define GUILE_APPEND_RESULT(object)                                      \
    if (gswig_result == GH_UNSPECIFIED)                                  \
        gswig_result = object;                                           \
    else {                                                               \
        if (!gh_pair_p(gswig_result))                                    \
	    gswig_result = gh_list(gswig_result, object, GH_NOT_PASSED); \
        else                                                             \
            gswig_result = gh_append2(gswig_result,                      \
                                      gh_list(object, GH_NOT_PASSED));   \
    }

static char *
GSWIG_scm2str (SCM s)
{
  int len = scm_string_length (s);
  return gh_scm2newstr (s, &len);
}

typedef struct SwigPtrType SwigPtrType;

/* Register a new type-mapping with the type-checker.  origtype is the
   original datatype and newtype is an equivalent type.  cast is optional
   pointer to a function to cast pointer values between types (this is
   typically used to cast pointers from derived classes to base classes in
   C++).  */

SWIGSTATIC
void SWIG_RegisterMapping (char *origtype, char *newtype,
                           void *(*cast)(void *));

/* Register SWIG smobs with Guile */
SWIGSTATIC
void SWIG_Guile_Init();

/* Initialization function for this SWIG module; actually renamed by a
   #define */
/* extern void SWIG_init(); */

/* TRANSITIONAL functions (used if -with-smobs) */

/* Makes a smob from a pointer and typestring. */

SWIGSTATIC
SCM SWIG_Guile_MakePtr_Str(void *ptr, char *typestring,
			   char *prettytypestring);

/* Gets a pointer value from a string. If there is a type-mismatch, returns
   nonzero; on success, return 0. */

SWIGSTATIC
int SWIG_Guile_GetPtr_Str(SCM s, void **result, char *typestring);

/* UPCOMING functions (not yet used) */
SWIGSTATIC
int SWIG_Guile_GetPtr(SCM s, void **result, SwigPtrType *type);

SWIGSTATIC
SCM SWIG_Guile_MakePtr(void *ptr, SwigPtrType *type);

#ifdef __cplusplus
}
#endif

/* guiledec.swg ends here */
