/* -*- c -*-
 * -----------------------------------------------------------------------
 * swig_lib/mzscheme/mzrun.swg
 * 
 * Author: John Lenz <jelenz@students.wisc.edu>
 * ----------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <escheme.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Common SWIG API */
  
#define SWIG_ConvertPtr(s, result, type, flags) \
  SWIG_MzScheme_ConvertPtr(s, result, type, flags)
#define SWIG_NewPointerObj(ptr, type, owner) \
  SWIG_MzScheme_NewPointerObj((void *)ptr, type, owner)
#define SWIG_MustGetPtr(s, type, argnum, flags) \
  SWIG_MzScheme_MustGetPtr(s, type, argnum, flags, FUNC_NAME, argc, argv)

/* MzScheme-specific SWIG API */
  
#define SWIG_malloc(size) SWIG_MzScheme_Malloc(size, FUNC_NAME)
#define SWIG_free(mem) free(mem)

#define MAXVALUES 6
#define swig_make_boolean(b) (b ? scheme_true : scheme_false)

#ifdef SWIG_NOINCLUDE

SWIGIMPORT(void) SWIG_MzScheme_Init();
/* If there is a type-mismatch, return nonzero; on success, return 0.  */
SWIGIMPORT(int) SWIG_MzScheme_ConvertPtr(Scheme_Object *s, void **result, swig_type_info *type, int flags);
/* If there is a type-mismatch, signal a wrong-type-arg error for the given argument number. */
SWIGIMPORT(void *) SWIG_MzScheme_MustGetPtr(Scheme_Object *s, swig_type_info *type, 
                                            int argnum, int flags, const char *func_name,
                                            int argc, Scheme_Object **argv);
SWIGIMPORT(Scheme_Object *) SWIG_MzScheme_NewPointerObj(void *ptr, swig_type_info *type, int owner);
SWIGIMPORT(void *) SWIG_MzScheme_Malloc(size_t size, const char *func_name);
SWIGIMPORT(Scheme_Object *) SWIG_MzScheme_PackageValues(int num, Scheme_Object **values);

#else

struct swig_mz_proxy {
  Scheme_Type mztype;
  swig_type_info *type;
  void *object;
};

static Scheme_Type swig_type;
static int swig_mz_initialized = 0;

static void mz_free_swig(void *p, void *data) {
  struct swig_mz_proxy *proxy = (struct swig_mz_proxy *) p;
  if (SCHEME_NULLP((Scheme_Object*)p) || SCHEME_TYPE((Scheme_Object*)p) != swig_type)
    return;
  if (proxy->type) {
    if (proxy->type->clientdata) {
      ((Scheme_Prim *)proxy->type->clientdata)(1, (Scheme_Object **)&proxy);
    }
  }
}

SWIGRUNTIME(Scheme_Object *)
SWIG_MzScheme_NewPointerObj(void *ptr, swig_type_info *type, int owner) {
  struct swig_mz_proxy *new_proxy;
  new_proxy = (struct swig_mz_proxy *) scheme_malloc(sizeof(struct swig_mz_proxy));
  new_proxy->mztype = swig_type;
  new_proxy->type = type;
  new_proxy->object = ptr;
  if (owner) {
    scheme_add_finalizer(new_proxy, mz_free_swig, NULL);
  }
  return (Scheme_Object *) new_proxy;
}

SWIGRUNTIME(int) 
SWIG_MzScheme_ConvertPtr(Scheme_Object *s, void **result, swig_type_info *type, int flags) {
  swig_type_info *cast;

  if (SCHEME_NULLP(s)) {
    *result = NULL;
    return 0;
  } else if (SCHEME_TYPE(s) == swig_type) {
    struct swig_mz_proxy *proxy = (struct swig_mz_proxy *) s;
    if (type) {
      cast = SWIG_TypeCheck((char *)proxy->type->name, type);
      if (cast) {
        *result = SWIG_TypeCast(cast, proxy->object);
        return 0;
      } else {
        return 1;
      }
    } else {
      *result = proxy->object;
      return 0;
    }
  }
  return 1;
}

SWIGRUNTIME(void *) 
SWIG_MzScheme_MustGetPtr(Scheme_Object *s, swig_type_info *type, 
                         int argnum, int flags, const char *func_name,
                         int argc, Scheme_Object **argv) {
  void *result;
  if (SWIG_MzScheme_ConvertPtr(s, &result, type, flags)) {
    scheme_wrong_type(func_name, type->str ? type->str : "void *", argnum - 1, argc, argv);
  }
  return result;
}

SWIGRUNTIME(void)
SWIG_MzScheme_Init() {
  if (!swig_mz_initialized) {
    swig_type = scheme_make_type((char *)"swig");
    swig_mz_initialized = 1;
  }
}

SWIGRUNTIME(void *) 
SWIG_MzScheme_Malloc(size_t size, const char *func_name) {
  void *p = malloc(size);
  if (p == NULL) {
    scheme_signal_error("swig-memory-error");
  } else return p;
}

SWIGIMPORT(Scheme_Object *) 
SWIG_MzScheme_PackageValues(int num, Scheme_Object **values) {
    /* ignore first value if void */
    if (num > 0 && SCHEME_VOIDP(values[0]))
	num--, values++;
    if (num == 0) return scheme_void;
    else if (num == 1) return values[0];
    else return scheme_values(num, values);
}

#endif

#ifdef __cplusplus
}
#endif
