/* -*- c -*-
 * -----------------------------------------------------------------------
 * swig_lib/mzscheme/mzrun.swg
 * 
 * Author: John Lenz <lenz@cs.wisc.edu>
 * ----------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
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

#define SWIG_contract_assert(expr,msg) \
 if (!(expr)) { \
    char *m=(char *) scheme_malloc(strlen(msg)+1000); \
    sprintf(m,"SWIG contract, assertion failed: function=%s, message=%s", \
            (char *) FUNC_NAME,(char *) msg); \
    scheme_signal_error(m); \
 }

/* Runtime API */
#define SWIG_GetModule(clientdata) SWIG_MzScheme_GetModule((Scheme_Env *)(clientdata))
#define SWIG_SetModule(clientdata, pointer) SWIG_MzScheme_SetModule((Scheme_Env *) (clientdata), pointer)
#define SWIG_MODULE_CLIENTDATA_TYPE Scheme_Env *

/* MzScheme-specific SWIG API */
  
#define SWIG_malloc(size) SWIG_MzScheme_Malloc(size, FUNC_NAME)
#define SWIG_free(mem) free(mem)
#define SWIG_NewStructFromPtr(ptr,type) \
        _swig_convert_struct_##type##(ptr)

#define MAXVALUES 6
#define swig_make_boolean(b) (b ? scheme_true : scheme_false)

static long
SWIG_convert_integer(Scheme_Object *o,
		     long lower_bound, long upper_bound, 
		     const char *func_name, int argnum, int argc,
		     Scheme_Object **argv)
{
  long value;
  int status = scheme_get_int_val(o, &value);
  if (!status)
    scheme_wrong_type(func_name, "integer", argnum, argc, argv);
  if (value < lower_bound || value > upper_bound)
    scheme_wrong_type(func_name, "integer", argnum, argc, argv);
  return value;
}

static int
SWIG_is_integer(Scheme_Object *o)
{
  long value;
  return scheme_get_int_val(o, &value);
}

static unsigned long
SWIG_convert_unsigned_integer(Scheme_Object *o,
			      unsigned long lower_bound, unsigned long upper_bound, 
			      const char *func_name, int argnum, int argc,
			      Scheme_Object **argv)
{
  unsigned long value;
  int status = scheme_get_unsigned_int_val(o, &value);
  if (!status)
    scheme_wrong_type(func_name, "integer", argnum, argc, argv);
  if (value < lower_bound || value > upper_bound)
    scheme_wrong_type(func_name, "integer", argnum, argc, argv);
  return value;
}

static int
SWIG_is_unsigned_integer(Scheme_Object *o)
{
  unsigned long value;
  return scheme_get_unsigned_int_val(o, &value);
}
  
/* ----------------------------------------------------------------------- 
 * mzscheme 30X support code
 * Contributed by Hans Oesterholt
 * ----------------------------------------------------------------------- */

#ifndef SCHEME_STR_VAL
#define MZSCHEME30X 1
#endif

#ifdef MZSCHEME30X 
/* 
 * This is MZSCHEME 299.100 or higher (30x).  From version 299.100 of
 * mzscheme upwards, strings are in unicode. These functions convert
 * to and from utf8 encodings of these strings.  NB! strlen(s) will be
 * the size in bytes of the string, not the actual length.
 */
#define SCHEME_STR_VAL(obj)  	       SCHEME_BYTE_STR_VAL(scheme_char_string_to_byte_string(obj))
#define SCHEME_STRLEN_VAL(obj)         SCHEME_BYTE_STRLEN_VAL(scheme_char_string_to_byte_string(obj))
#define SCHEME_STRINGP(obj)            SCHEME_CHAR_STRINGP(obj)
#define scheme_make_string(s)          scheme_make_utf8_string(s)
#define scheme_make_sized_string(s,l)  scheme_make_sized_utf8_string(s,l)
#define scheme_make_sized_offset_string(s,d,l) \
                   scheme_make_sized_offset_utf8_string(s,d,l)
#define SCHEME_MAKE_STRING(s) scheme_make_utf8_string(s)
#else
#define SCHEME_MAKE_STRING(s) scheme_make_string_without_copying(s)
#endif
/* ----------------------------------------------------------------------- 
 * End of mzscheme 30X support code 
 * ----------------------------------------------------------------------- */
  
struct swig_mz_proxy {
  Scheme_Type mztype;
  swig_type_info *type;
  void *object;
};

static Scheme_Type swig_type;

static void 
mz_free_swig(void *p, void *data) {
  struct swig_mz_proxy *proxy = (struct swig_mz_proxy *) p;
  if (SCHEME_NULLP((Scheme_Object*)p) || SCHEME_TYPE((Scheme_Object*)p) != swig_type)
    return;
  if (proxy->type) {
    if (proxy->type->clientdata) {
      ((Scheme_Prim *)proxy->type->clientdata)(1, (Scheme_Object **)&proxy);
    }
  }
}

static Scheme_Object *
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

static int
SWIG_MzScheme_ConvertPtr(Scheme_Object *s, void **result, swig_type_info *type, int flags) {
  swig_cast_info *cast;

  if (SCHEME_NULLP(s)) {
    *result = NULL;
    return 0;
  } else if (SCHEME_TYPE(s) == swig_type) {
    struct swig_mz_proxy *proxy = (struct swig_mz_proxy *) s;
    if (type) {
      cast = SWIG_TypeCheckStruct(proxy->type, type);
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

static SWIGINLINE void *
SWIG_MzScheme_MustGetPtr(Scheme_Object *s, swig_type_info *type, 
                         int argnum, int flags, const char *func_name,
                         int argc, Scheme_Object **argv) {
  void *result;
  if (SWIG_MzScheme_ConvertPtr(s, &result, type, flags)) {
    scheme_wrong_type(func_name, type->str ? type->str : "void *", argnum - 1, argc, argv);
  }
  return result;
}

static SWIGINLINE void *
SWIG_MzScheme_Malloc(size_t size, const char *func_name) {
  void *p = malloc(size);
  if (p == NULL) {
    scheme_signal_error("swig-memory-error");
  } else return p;
}

static Scheme_Object *
SWIG_MzScheme_PackageValues(int num, Scheme_Object **values) {
    /* ignore first value if void */
    if (num > 0 && SCHEME_VOIDP(values[0]))
	num--, values++;
    if (num == 0) return scheme_void;
    else if (num == 1) return values[0];
    else return scheme_values(num, values);
}

#ifndef scheme_make_inspector
#define scheme_make_inspector(x,y) \
        _scheme_apply(scheme_builtin_value("make-inspector"), x, y)
#endif

/* Function to create a new struct. */
static Scheme_Object *
SWIG_MzScheme_new_scheme_struct (Scheme_Env* env, const char* basename, 
				 int num_fields, char** field_names)
{
    Scheme_Object *new_type;
    int count_out, i;
    Scheme_Object **struct_names;
    Scheme_Object **vals;
    Scheme_Object **a = (Scheme_Object**) \
        scheme_malloc(num_fields*sizeof(Scheme_Object*));
    
    for (i=0; i<num_fields; ++i) {
        a[i] = (Scheme_Object*) scheme_intern_symbol(field_names[i]);
    }

    new_type = scheme_make_struct_type(scheme_intern_symbol(basename),
                                       NULL /*super_type*/,
                                       scheme_make_inspector(0, NULL),
                                       num_fields,
                                       0 /* auto_fields */,
                                       NULL /* auto_val */,
                                       NULL /* properties */
#ifdef MZSCHEME30X
				       ,NULL /* Guard */
#endif
				       );
    struct_names = scheme_make_struct_names(scheme_intern_symbol(basename),
                                            scheme_build_list(num_fields,a),
                                            0 /*flags*/, &count_out);
    vals = scheme_make_struct_values(new_type, struct_names, count_out, 0);

    for (i = 0; i < count_out; i++)
        scheme_add_global_symbol(struct_names[i], vals[i],env);

    return new_type;
}

/* The interpreter will store a pointer to this structure in a global
   variable called swig-runtime-data-type-pointer.  The instance of this
   struct is only used if no other module has yet been loaded */
struct swig_mzscheme_runtime_data {
  swig_module_info *module_head;
  Scheme_Type type;
};
static struct swig_mzscheme_runtime_data swig_mzscheme_runtime_data;


static swig_module_info *
SWIG_MzScheme_GetModule(Scheme_Env *env) {
  Scheme_Object *pointer, *symbol;
  struct swig_mzscheme_runtime_data *data;

  /* first check if pointer already created */
  symbol = scheme_intern_symbol("swig-runtime-data-type-pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME);
  pointer = scheme_lookup_global(symbol, env);
  if (pointer && SCHEME_CPTRP(pointer)) {
      data = (struct swig_mzscheme_runtime_data *) SCHEME_CPTR_VAL(pointer);
      swig_type = data->type;
      return data->module_head;
  } else {
      return NULL;
  }
}

static void
SWIG_MzScheme_SetModule(Scheme_Env *env, swig_module_info *module) {
  Scheme_Object *pointer, *symbol;
  struct swig_mzscheme_runtime_data *data;

  /* first check if pointer already created */
  symbol = scheme_intern_symbol("swig-runtime-data-type-pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME);
  pointer = scheme_lookup_global(symbol, env);
  if (pointer && SCHEME_CPTRP(pointer)) {
    data = (struct swig_mzscheme_runtime_data *) SCHEME_CPTR_VAL(pointer);
    swig_type = data->type;
    data->module_head = module;
  } else {
    /* create a new type for wrapped pointer values */
    swig_type = scheme_make_type((char *)"swig");
    swig_mzscheme_runtime_data.module_head = module;
    swig_mzscheme_runtime_data.type = swig_type;
    
    /* create a new pointer */
#ifndef MZSCHEME30X
    pointer = scheme_make_cptr((void *) &swig_mzscheme_runtime_data, "swig_mzscheme_runtime_data");
#else
    pointer = scheme_make_cptr((void *) &swig_mzscheme_runtime_data,
			       scheme_make_byte_string("swig_mzscheme_runtime_data"));
#endif
    scheme_add_global_symbol(symbol, pointer, env);
  }
}

#ifdef __cplusplus
}
#endif
