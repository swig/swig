/* -*- c -*-
 * -----------------------------------------------------------------------
 * swig_lib/guile/guile_scm_run.swg
 *
 * Author: John Lenz <jelenz@students.wisc.edu>
 * ----------------------------------------------------------------------- */

#include <libguile.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef SCM (*swig_guile_proc)();
typedef SCM (*guile_destructor)(SCM);

#define SWIG_scm2str(s) SWIG_scm2newstr(s, NULL)

#define SWIG_malloc(size) \
  SCM_MUST_MALLOC(size)
#define SWIG_free(mem) \
  scm_must_free(mem)
#define SWIG_ConvertPtr(s, result, type, flags) \
  SWIG_Guile_ConvertPtr(s, result, type, flags)
#define SWIG_MustGetPtr(s, type, argnum, flags) \
  SWIG_Guile_MustGetPtr(s, type, argnum, flags, FUNC_NAME)
#define SWIG_NewPointerObj(ptr, type, owner) \
  SWIG_Guile_NewPointerObj((void*)ptr, type, owner)

#ifdef SWIG_NOINCLUDE

/* Interface helper function */
SWIGIMPORT(char *) SWIG_scm2newstr(SCM str, size_t *len);

/* Register SWIG smobs with Guile.  */
SWIGIMPORT(void) SWIG_Guile_Init();
/* Get a pointer value from a smob.  If there is a type-mismatch,
   return nonzero; on success, return 0.  */
SWIGIMPORT(int) SWIG_Guile_ConvertPtr(SCM s, void **result, swig_type_info *type, int flags);
/* Get a pointer value from a smob.  If there is a type-mismatch,
   signal a wrong-type-arg error for the given argument number. */
SWIGIMPORT(void *) SWIG_Guile_MustGetPtr(SCM s, swig_type_info *type, int argnum, int flags, const char *func_name);
/* Make a smob from a pointer and typeinfo.  */
SWIGIMPORT(SCM) SWIG_Guile_NewPointerObj(void *ptr, swig_type_info *type, int owner);
/* Get arguments from an argument list */
SWIGIMPORT(int) SWIG_Guile_GetArgs(SCM *dest, SCM rest, int reqargs, int optargs, const char *procname);

#else

SWIGRUNTIME(char *) 
SWIG_scm2newstr(SCM str, size_t *len) {
#define FUNC_NAME "swig_scm2newstr"
  char *ret;
  size_t l;

  l = SCM_STRING_LENGTH(str);
  ret = (char *) SWIG_malloc( (l + 1) * sizeof(char));
  if (!ret) return NULL;

  memcpy(ret, SCM_STRING_CHARS(str), l);
  ret[l] = '\0';
  if (len) *len = l;
  return ret;
#undef FUNC_NAME
}

static scm_t_bits swig_tag = 0;
static scm_t_bits swig_collected_tag = 0;

SWIGRUNTIME(SCM)
SWIG_Guile_NewPointerObj(void *ptr, swig_type_info *type, int owner)
{
  if (owner)
    SCM_RETURN_NEWSMOB2(swig_collected_tag, ptr, (void *) type);
  else
    SCM_RETURN_NEWSMOB2(swig_tag, ptr, (void *) type);
}

/* Return 0 if successful. */
SWIGRUNTIME(int)
SWIG_Guile_ConvertPtr(SCM s, void **result, swig_type_info *type, int flags)
{
  swig_type_info *cast;
  swig_type_info *from;
  if (SCM_NULLP(s)) {
    *result = NULL;
    return 0;
  } else if (SCM_SMOB_PREDICATE(swig_tag, s) || SCM_SMOB_PREDICATE(swig_collected_tag, s)) {
    from = (swig_type_info *) SCM_CELL_WORD_2(s);
    if (!from) return 1;
    if (type) {
      cast = SWIG_TypeCheck((char*)from->name, type);
      if (cast) {
        *result = SWIG_TypeCast(cast, (void *) SCM_CELL_WORD_1(s));
        return 0;
      } else {
        return 1;
      }
    } else {
      *result = (void *) SCM_CELL_WORD_1(s);
      return 0;
    }
  }
  return 1;
}

SWIGRUNTIME(void *)
SWIG_Guile_MustGetPtr (SCM s, swig_type_info *type,
		       int argnum, int flags, const char *func_name)
{
  void *result;
  if (SWIG_Guile_ConvertPtr(s, &result, type, flags)) {
    /* type mismatch */
    scm_wrong_type_arg((char *) func_name, argnum, s);
  }
  return result;
}

/* Init */

static int
print_swig (SCM swig_smob, SCM port, scm_print_state *pstate)
{
  swig_type_info *type = (swig_type_info *) SCM_CELL_WORD_2(swig_smob);
  if (type) {
    scm_puts((char *) "#<swig ", port);
    if (type->str != NULL)
      scm_puts(type->str, port);
    else 
      scm_puts(type->name, port);
    scm_puts((char *) " ", port);
    scm_intprint((long) SCM_CELL_WORD_1(swig_smob), 16, port);
    scm_puts((char *) ">", port);
    /* non-zero means success */
    return 1;
  } else {
    return 0;
  }
}

static int
print_collected_swig (SCM swig_smob, SCM port, scm_print_state *pstate)
{
  swig_type_info *type = (swig_type_info *) SCM_CELL_WORD_2(swig_smob);
  if (type) {
    scm_puts((char *) "#<collected swig ", port);
    if (type->str != NULL)
      scm_puts(type->str, port);
    else 
      scm_puts(type->name, port);
    scm_puts((char *) " ", port);
    scm_intprint((long) SCM_CELL_WORD_1(swig_smob), 16, port);
    scm_puts((char *) ">", port);
    /* non-zero means success */
    return 1;
  } else {
    return 0;
  }
}

static SCM
equalp_swig (SCM A, SCM B)
{
  if (SCM_CAR(A) == SCM_CAR(B) && SCM_CELL_WORD_1(A) == SCM_CELL_WORD_1(B) 
      && SCM_CELL_WORD_2(A) == SCM_CELL_WORD_2(B))
    return SCM_BOOL_T;
  else return SCM_BOOL_F;
}

static size_t
free_swig(SCM A)
{
  swig_type_info *type = (swig_type_info *) SCM_CELL_WORD_2(A);
  if (type) {
    if (type->clientdata)
      ((guile_destructor)type->clientdata)(A);
  } 
  return 0;
}

SWIGRUNTIME(void)
SWIG_Guile_Init ()
{
  if (!swig_tag) {
    swig_tag = scm_make_smob_type((char*)"swig", 0);
    scm_set_smob_print(swig_tag, print_swig);
    scm_set_smob_equalp(swig_tag, equalp_swig);
  }

  if (!swig_collected_tag) {
    swig_collected_tag = scm_make_smob_type((char*)"collected swig", 0);
    scm_set_smob_print(swig_collected_tag, print_collected_swig);
    scm_set_smob_equalp(swig_collected_tag, equalp_swig);
    scm_set_smob_free(swig_collected_tag, free_swig);
  }
}

SWIGRUNTIME(int)
SWIG_Guile_GetArgs (SCM *dest, SCM rest,
		    int reqargs, int optargs,
		    const char *procname)
{
  int i;
  int num_args_passed = 0;
  for (i = 0; i<reqargs; i++) {
    if (!SCM_CONSP(rest))
      scm_wrong_num_args(scm_makfrom0str((char *) procname));
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
    *dest++ = SCM_UNDEFINED;
  if (!SCM_NULLP(rest))
    scm_wrong_num_args(scm_makfrom0str((char *) procname));
  return num_args_passed;
}

#endif

#ifdef __cplusplus
}
#endif
