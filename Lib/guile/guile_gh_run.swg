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

#define SWIG_RUNTIME_VERSION "1"
/* define SWIG_TYPE_TABLE_NAME as "SWIG_TYPE_TABLE" */
#ifdef SWIG_TYPE_TABLE
#define SWIG_QUOTE_STRING(x) #x
#define SWIG_EXPAND_AND_QUOTE_STRING(x) SWIG_QUOTE_STRING(x)
#define SWIG_TYPE_TABLE_NAME SWIG_EXPAND_AND_QUOTE_STRING(SWIG_TYPE_TABLE)
#else
#define SWIG_TYPE_TABLE_NAME
#endif

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

static void
SWIG_Guile_RegisterTypes (swig_type_info **table,
			  swig_type_info **init);

/* Register a new type-mapping with the type-checker.  origtype is the
   original datatype and newtype is an equivalent type.  cast is optional
   pointer to a function to cast pointer values between types (this is
   typically used to cast pointers from derived classes to base classes in
   C++).  */

static void
SWIG_RegisterMapping (const char *origtype, const char *newtype,
                      swig_converter_func cast);


/* Dynamic pointer casting. Down an inheritance hierarchy */
static swig_type_info * 
SWIG_TypeDynamicCast(swig_type_info *ty, void **ptr);

/* Register SWIG smobs with Guile.  */
static void
SWIG_Guile_Init();

/* Initialization function for this SWIG module; actually renamed by a
   #define */
/* extern void SWIG_init(); */

/* Get a pointer value from a smob.  If there is a type-mismatch,
   return nonzero; on success, return 0.  */
static int
SWIG_Guile_GetPtr (SCM s, void **result, swig_type_info *type);

/* Get a pointer value from a smob.  If there is a type-mismatch,
   signal a wrong-type-arg error for the given argument number. */
static void *
SWIG_Guile_MustGetPtr (SCM s, swig_type_info *type,
		       int argnum, const char *func_name);

/* Make a smob from a pointer and typeinfo.  */
static SCM
SWIG_Guile_MakePtr (void *ptr, swig_type_info *type);

/* Get arguments from an argument list */
static int
SWIG_Guile_GetArgs (SCM *dest, SCM rest,
		    int reqargs, int optargs,
		    const char *procname);

typedef SCM (*swig_guile_proc)();

#ifdef __cplusplus
}
#endif

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

struct swig_module_info {
  int PtrMax;/* Max entries that can be held *//* (may be adjusted dynamically) */
  int PtrN;/* Current number of entries */
  int PtrSort;/* Status flag indicating sort */
  SwigPtrType *PtrList;    /* Table containing types and
					   equivalences; items will only
                                           be appended */
  size_t *PtrTbl;/* Sorted indirect table; items will be inserted */

  unsigned long swig_tag;

};

static struct swig_module_info SwigModuleLocal = {64,0,0,0,0,0};
static struct swig_module_info *SwigModule = &SwigModuleLocal;

/* Sort comparison function */
static int
swigsort (const void *data1, const void *data2)
{
  size_t index1 = * (size_t *) data1;
  size_t index2 = * (size_t *) data2;
  return strcmp(SwigModule->PtrList[index1].name, SwigModule->PtrList[index2].name);
}

/* Register a new datatype with the type-checker */
static size_t
SWIG_RegisterType (const char *type, const char *prettyname)
{
  int i;

  /* Allocate the pointer table if necessary */
  if (!SwigModule->PtrList) {
    SwigModule->PtrList = (SwigPtrType *) malloc(SwigModule->PtrMax*sizeof(SwigPtrType));
    SwigModule->PtrTbl = (size_t *) malloc(SwigModule->PtrMax*sizeof(size_t));
    SwigModule->PtrN = 0;
  }
  /* Grow the table if necessary */
  if (SwigModule->PtrN >= SwigModule->PtrMax) {
    SwigModule->PtrMax = 2*SwigModule->PtrMax;
    SwigModule->PtrList = (SwigPtrType *) realloc((char *) SwigModule->PtrList,
					  SwigModule->PtrMax*sizeof(SwigPtrType));
    SwigModule->PtrTbl = (size_t *) realloc((char *) SwigModule->PtrTbl,
				    SwigModule->PtrMax*sizeof(size_t));
  }
  /* Look up type */
  for (i = 0; i < SwigModule->PtrN; i++)
    if (strcmp(SwigModule->PtrList[i].name,type) == 0) {
      if (prettyname!=NULL)
	SwigModule->PtrList[i].prettyname = prettyname;
      return i;
    }
  {
    struct SwigPtrType *t;
    size_t tag;
#if 0
    fprintf(stderr, "New type: %s\n", type);
#endif
    tag = SwigModule->PtrTbl[SwigModule->PtrN] = SwigModule->PtrN;
    t = &SwigModule->PtrList[tag];
    t->name = type;
    t->prettyname = prettyname;
    t->tag = SwigModule->PtrN;
    t->cast = NULL;
    SwigModule->PtrN++;
    SwigModule->PtrSort = 0; 
    return tag;
  }
}

/* Register two data types and their mapping with the type checker. */
static void
SWIG_RegisterMapping (const char *origtype, const char *newtype,
		      swig_converter_func cast)
{
  size_t t = SWIG_RegisterType(origtype, NULL);

  if (newtype!=NULL) {
    size_t t1 = SWIG_RegisterType(newtype, NULL);
    struct SwigCast *c;
    /* Check for existing cast */
    for (c = SwigModule->PtrList[t].cast; c && c->type!=t1; c=c->next) /* nothing */;
    if (c) {
      if (cast) c->cast = cast;
    }
    else {
      c = (struct SwigCast *) malloc(sizeof(struct SwigCast));
      c->type = t1;
      c->cast = cast;
      c->next = SwigModule->PtrList[t].cast;
      SwigModule->PtrList[t].cast = c;
    }
  }
}

/* Sort table */

static void
SWIG_SortTable (void)
{
  qsort ((void *) SwigModule->PtrTbl, SwigModule->PtrN, sizeof(size_t), swigsort);
  /* Indicate that everything is sorted */
  SwigModule->PtrSort = 1;
}

/* Look up pointer-type entry in table */

static int
swigcmp (const void *key, const void *data)
{
  char *k = (char *) key;
  size_t index = *(size_t *)data;
  return strcmp(k, SwigModule->PtrList[index].name);
}

static SwigPtrType *
SWIG_GetPtrType (const char *_t)
{
  size_t *result;
  if (!SwigModule->PtrSort) SWIG_SortTable();
  result = (size_t *) bsearch(_t, SwigModule->PtrTbl, SwigModule->PtrN, sizeof(size_t), swigcmp);
  if (result!=NULL) return SwigModule->PtrList+*result;
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
    for (c = SwigModule->PtrList[dest_type].cast;
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
static swig_type_info * 
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

static SCM
SWIG_Guile_MakePtr (void *ptr, swig_type_info *type)
{
  if (ptr==NULL) return SCM_EOL;
  SCM_RETURN_NEWSMOB((((unsigned long)type->tag << 16) | SwigModule->swig_tag),
		     ptr);
}

/* Return 0 if successful. */
static int
SWIG_Guile_GetPtr(SCM s, void **result, swig_type_info *type)
{
  if (SCM_NULLP(s)) {
    *result = NULL;
    return 0;
  }
  else if (SCM_NIMP(s)
	   && (unsigned long) SCM_TYP16(s) == SwigModule->swig_tag) {
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

static void *
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
  if (SwigModule->PtrList[(long) SCM_CAR(swig_smob) >> 16].prettyname != NULL)
    scm_puts((char*) SwigModule->PtrList[(long) SCM_CAR(swig_smob) >> 16].prettyname, port);
  else scm_puts((char*) SwigModule->PtrList[(long) SCM_CAR(swig_smob) >> 16].name, port);
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

static void
SWIG_Guile_Init (void)
{
  SCM pointer;

  pointer = gh_lookup("swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME);
  if (pointer == SCM_UNDEFINED) {
    pointer = gh_ulong2scm((unsigned long)SwigModule);
    gh_define("swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, pointer);
    if (SwigModule->swig_tag == 0) {
      SwigModule->swig_tag = scm_make_smob_type_mfpe((char *) "swig", 0, NULL, NULL,
				       print_swig, equalp_swig);
    }
  } else {
   SwigModule = (struct swig_module_info *) gh_scm2ulong(pointer); 
  }
}

/* Convert datatype table */

static
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

static int
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
