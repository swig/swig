/* -*- c -*-
 * -----------------------------------------------------------------------
 * Lib/guile/guile_gh_run.swg
 *
 * Guile GH runtime file
 * Copyright (C) 2000 Matthias Koeppe
 * ----------------------------------------------------------------------- */

#include "guile/gh.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#define SWIG_malloc(size) \
  SCM_MUST_MALLOC(size)
#define SWIG_free(mem) \
  scm_must_free(mem)
#define SWIG_ConvertPtr(s, result, type, flags) \
  SWIG_Guile_GetPtr(s, result, type)
#define SWIG_MustGetPtr(s, type, argnum, flags) \
  SWIG_Guile_MustGetPtr(s, type, argnum, FUNC_NAME)
#define SWIG_NewPointerObj(ptr, type, owner) \
  SWIG_Guile_MakePtr((void*)ptr, type)

/* Ignore object-ownership changes in gh mode */
#define SWIG_Guile_MarkPointerNoncollectable(s) (s)
#define SWIG_Guile_MarkPointerDestroyed(s) (s)
  
#define SWIG_contract_assert(expr, msg)				\
  if (!(expr))							\
    scm_error(gh_symbol2scm("swig-contract-assertion-failed"),	\
	      (char *) FUNC_NAME, (char *) msg,			\
	      SCM_EOL, SCM_BOOL_F); else

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
  swig_dycast_func        dcast;
  size_t tag;
  int dummy;
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

#ifndef SWIG_NOINCLUDE
/* SWIG pointer structure */

#ifdef __cplusplus
extern "C" {
#endif

struct SwigCast {
  unsigned short      type;		  /* Index into SwigPtrTbl          */
  void               *(*cast)(void *);    /* Pointer casting function       */
  struct SwigCast    *next;		  /* Linked list pointer            */
};

struct SwigPtrType {
  const char         *name;               /* Datatype name                  */
  const char	     *prettyname;         /* Pretty datatype name           */
  unsigned short      tag;		  /* Index in SwigPtrTable          */
  struct SwigCast    *cast;		  /* List of compatible types       */
};

/* Some variables  */

static int SwigPtrMax  = 64;            /* Max entries that can be held */
                                        /* (may be adjusted dynamically) */
static int SwigPtrN    = 0;             /* Current number of entries */
static int SwigPtrSort = 0;             /* Status flag indicating sort */

/* Pointer table */
static SwigPtrType *SwigPtrList = 0;    /* Table containing types and
					   equivalences; items will only
                                           be appended */
static size_t *SwigPtrTbl = 0;          /* Sorted indirect table; items will
					   be inserted */

/* Sort comparison function */
static int
swigsort (const void *data1, const void *data2)
{
  size_t index1 = * (size_t *) data1;
  size_t index2 = * (size_t *) data2;
  return strcmp(SwigPtrList[index1].name, SwigPtrList[index2].name);
}

/* Register a new datatype with the type-checker */
SWIGSTATIC size_t
SWIG_RegisterType (const char *type, const char *prettyname)
{
  int i;

  /* Allocate the pointer table if necessary */
  if (!SwigPtrList) {
    SwigPtrList = (SwigPtrType *) malloc(SwigPtrMax*sizeof(SwigPtrType));
    SwigPtrTbl = (size_t *) malloc(SwigPtrMax*sizeof(size_t));
    SwigPtrN = 0;
  }
  /* Grow the table if necessary */
  if (SwigPtrN >= SwigPtrMax) {
    SwigPtrMax = 2*SwigPtrMax;
    SwigPtrList = (SwigPtrType *) realloc((char *) SwigPtrList,
					  SwigPtrMax*sizeof(SwigPtrType));
    SwigPtrTbl = (size_t *) realloc((char *) SwigPtrTbl,
				    SwigPtrMax*sizeof(size_t));
  }
  /* Look up type */
  for (i = 0; i < SwigPtrN; i++)
    if (strcmp(SwigPtrList[i].name,type) == 0) {
      if (prettyname!=NULL)
	SwigPtrList[i].prettyname = prettyname;
      return i;
    }
  {
    struct SwigPtrType *t;
    size_t tag;
#if 0
    fprintf(stderr, "New type: %s\n", type);
#endif
    tag = SwigPtrTbl[SwigPtrN] = SwigPtrN;
    t = &SwigPtrList[tag];
    t->name = type;
    t->prettyname = prettyname;
    t->tag = SwigPtrN;
    t->cast = NULL;
    SwigPtrN++;
    SwigPtrSort = 0; 
    return tag;
  }
}

/* Register two data types and their mapping with the type checker. */
SWIGSTATIC void
SWIG_RegisterMapping (const char *origtype, const char *newtype,
		      swig_converter_func cast)
{
  size_t t = SWIG_RegisterType(origtype, NULL);

  if (newtype!=NULL) {
    size_t t1 = SWIG_RegisterType(newtype, NULL);
    struct SwigCast *c;
    /* Check for existing cast */
    for (c = SwigPtrList[t].cast; c && c->type!=t1; c=c->next) /* nothing */;
    if (c) {
      if (cast) c->cast = cast;
    }
    else {
      c = (struct SwigCast *) malloc(sizeof(struct SwigCast));
      c->type = t1;
      c->cast = cast;
      c->next = SwigPtrList[t].cast;
      SwigPtrList[t].cast = c;
    }
  }
}

/* Sort table */

static void
SWIG_SortTable (void)
{
  qsort ((void *) SwigPtrTbl, SwigPtrN, sizeof(size_t), swigsort);
  /* Indicate that everything is sorted */
  SwigPtrSort = 1;
}

/* Look up pointer-type entry in table */

static int
swigcmp (const void *key, const void *data)
{
  char *k = (char *) key;
  size_t index = *(size_t *)data;
  return strcmp(k, SwigPtrList[index].name);
}

static SwigPtrType *
SWIG_GetPtrType (const char *_t)
{
  size_t *result;
  if (!SwigPtrSort) SWIG_SortTable();
  result = (size_t *) bsearch(_t, SwigPtrTbl, SwigPtrN, sizeof(size_t), swigcmp);
  if (result!=NULL) return SwigPtrList+*result;
  else return NULL;
}

/* Cast a pointer if possible; returns 1 if successful */

static int
SWIG_Cast (void *source, size_t source_type,
	   void **ptr, size_t dest_type)
{
  if (dest_type != source_type) {
    /* We have a type mismatch.  Will have to look through our type
       mapping table to figure out whether or not we can accept this
       datatype.  */
    struct SwigCast *c;
    for (c = SwigPtrList[dest_type].cast;
	 c && c->type!=source_type; c = c->next) /* nothing */;
    if (c) {
      /* Get pointer value. */
      if (c->cast) *ptr = (*(c->cast))(source);
      else *ptr = source;
      return 1;
    }
    /* Didn't find any sort of match for this data.
       Get the pointer value and return false.  */
    *ptr = source;
    return 0;
  } else {
    /* Found a match on the first try.  Return pointer value.  */
    *ptr = source;
    return 1;
  }
}

/* Dynamic pointer casting. Down an inheritance hierarchy */
SWIGSTATIC swig_type_info * 
SWIG_TypeDynamicCast(swig_type_info *ty, void **ptr) 
{
  swig_type_info *lastty = ty;
  if (!ty || !ty->dcast) return ty;
  while (ty && (ty->dcast)) {
     ty = (*ty->dcast)(ptr);
     if (ty) lastty = ty;
  }
  return lastty;
}

/* Function for getting a pointer value */

static unsigned long swig_tag = 0;

SWIGSTATIC SCM
SWIG_Guile_MakePtr (void *ptr, swig_type_info *type)
{
  if (ptr==NULL) return SCM_EOL;
  SCM_RETURN_NEWSMOB((((unsigned long)type->tag << 16) | swig_tag),
		     ptr);
}

/* Return 0 if successful. */
SWIGSTATIC int
SWIG_Guile_GetPtr(SCM s, void **result, swig_type_info *type)
{
  if (SCM_NULLP(s)) {
    *result = NULL;
    return 0;
  }
  else if (SCM_NIMP(s)
	   && (unsigned long) SCM_TYP16(s) == swig_tag) {
    if (type) 
      return !SWIG_Cast((void *) SCM_CDR(s),
			(long) SCM_CAR(s) >> 16,
			result, type->tag);
    else {
      *result = (void *) SCM_CDR(s);
      return 0;
    }
  }
  return 1;
}

SWIGSTATIC void *
SWIG_Guile_MustGetPtr (SCM s, swig_type_info *type,
		       int argnum, const char *func_name)
{
  void *result;
  if (SWIG_Guile_GetPtr(s, &result, type)) {
    /* type mismatch */
    scm_wrong_type_arg((char *) func_name, argnum, s);
  }
  return result;
}

/* Init */

static int
print_swig (SCM swig_smob, SCM port, scm_print_state *pstate)
{
  scm_puts((char *) "#<swig ", port);
  if (SwigPtrList[(long) SCM_CAR(swig_smob) >> 16].prettyname != NULL)
    scm_puts((char*) SwigPtrList[(long) SCM_CAR(swig_smob) >> 16].prettyname, port);
  else scm_puts((char*) SwigPtrList[(long) SCM_CAR(swig_smob) >> 16].name, port);
  scm_puts((char *) " ", port);
  scm_intprint((long) SCM_CDR(swig_smob), 16, port);
  scm_puts((char *) ">", port);
  /* non-zero means success */
  return 1;
}

static SCM
equalp_swig (SCM A, SCM B)
{
  if (SCM_CAR(A) == SCM_CAR(B)
      && SCM_CDR(A) == SCM_CDR(B))
    return SCM_BOOL_T;
  else return SCM_BOOL_F;
}

SWIGSTATIC void
SWIG_Guile_Init (void)
{
  if (swig_tag == 0) {
    swig_tag = scm_make_smob_type_mfpe((char *) "swig", 0, NULL, NULL,
				       print_swig, equalp_swig);
  }
}

/* Convert datatype table */

SWIGSTATIC
void SWIG_Guile_RegisterTypes(swig_type_info **table,
			      swig_type_info **init)
{
  for (; *init; table++, init++) {
    swig_type_info *type = *table = *init;
    const char *origname = type->name;
    /* Register datatype itself and store pointer back */
    type->tag = SWIG_RegisterType(origname, type->str);
    /* Register compatible types */
    for (type++; type->name; type++)
      SWIG_RegisterMapping(origname, type->name, type->converter);
  }    
}

SWIGSTATIC int
SWIG_Guile_GetArgs (SCM *dest, SCM rest,
		    int reqargs, int optargs,
		    const char *procname)
{
  int i;
  int num_args_passed = 0;
  for (i = 0; i<reqargs; i++) {
    if (!SCM_CONSP(rest))
      scm_wrong_num_args(gh_str02scm((char *) procname));
    *dest++ = SCM_CAR(rest);
    rest = SCM_CDR(rest);
    num_args_passed++;
  }
  for (i = 0; i<optargs && SCM_CONSP(rest); i++) {
    *dest++ = SCM_CAR(rest);
    rest = SCM_CDR(rest);
    num_args_passed++;
  }
  for (; i<optargs; i++)
    *dest++ = GH_NOT_PASSED;
  if (!SCM_NULLP(rest))
    scm_wrong_num_args(gh_str02scm((char *) procname));
  return num_args_passed;
}

#ifdef __cplusplus
}
#endif

/* guile.swg ends here */

#endif
