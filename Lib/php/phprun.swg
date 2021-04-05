/* -----------------------------------------------------------------------------
 * phprun.swg
 *
 * PHP runtime library
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif
#include "zend.h"
#include "zend_API.h"
#include "zend_exceptions.h"
#include "php.h"

#if PHP_MAJOR_VERSION < 7
# error These bindings need PHP 7 or later - to generate PHP5 bindings use: SWIG < 4.0.0 and swig -php5
#endif

#include "ext/standard/php_string.h"
#include <stdlib.h> /* for abort(), used in generated code. */

#define SWIG_BOOL_CONSTANT(N, V) REGISTER_BOOL_CONSTANT(#N, V, CONST_CS | CONST_PERSISTENT)
#define SWIG_LONG_CONSTANT(N, V) REGISTER_LONG_CONSTANT(#N, V, CONST_CS | CONST_PERSISTENT)
#define SWIG_DOUBLE_CONSTANT(N, V) REGISTER_DOUBLE_CONSTANT(#N, V, CONST_CS | CONST_PERSISTENT)
#define SWIG_STRING_CONSTANT(N, V) REGISTER_STRING_CONSTANT(#N, (char*)V, CONST_CS | CONST_PERSISTENT)
#define SWIG_CHAR_CONSTANT(N, V) do {\
    char swig_char = (V);\
    REGISTER_STRINGL_CONSTANT(#N, &swig_char, 1, CONST_CS | CONST_PERSISTENT);\
} while (0)

/* ZEND_CONSTANT_SET_FLAGS was new in PHP 7.3. */
#ifdef ZEND_CONSTANT_SET_FLAGS
# define SWIG_ZEND_CONSTANT_SET_FLAGS ZEND_CONSTANT_SET_FLAGS
#else
# define SWIG_ZEND_CONSTANT_SET_FLAGS(C, F, N) do { (C)->flags = (F); (C)->module_number = (N); } while (0)
#endif

/* zend_object_alloc was new in PHP 7.3. */
#if PHP_MAJOR_VERSION == 7 && PHP_MINOR_VERSION < 3
static zend_always_inline void *zend_object_alloc(size_t obj_size, zend_class_entry *ce) {
    void *obj = emalloc(obj_size + zend_object_properties_size(ce));
    memset(obj, 0, obj_size - sizeof(zval));
    return obj;
}
#endif

/* ZEND_THIS was new in PHP 7.4. */
#ifndef ZEND_THIS
# define ZEND_THIS &EX(This)
#endif

#ifdef __cplusplus
}
#endif

#define SWIG_fail goto fail

static const char *default_error_msg = "Unknown error occurred";
static int default_error_code = E_ERROR;

#define SWIG_PHP_Arg_Error_Msg(argnum,extramsg) "Error in argument " #argnum " "#extramsg

#define SWIG_PHP_Error(code,msg) do { SWIG_ErrorCode() = code; SWIG_ErrorMsg() = msg; SWIG_fail; } while (0)

#define SWIG_contract_assert(expr,msg) \
  if (!(expr) ) { zend_printf("Contract Assert Failed %s\n",msg ); } else

/* Standard SWIG API */
#define SWIG_GetModule(clientdata) SWIG_Php_GetModule()
#define SWIG_SetModule(clientdata, pointer) SWIG_Php_SetModule(pointer, *(int*)clientdata)

/* used to wrap returned objects in so we know whether they are newobject
   and need freeing, or not */
typedef struct {
  void * ptr;
  int newobject;
  zend_object std;
} swig_object_wrapper;

#define SWIG_Z_FETCH_OBJ_P(zv) php_fetch_object(Z_OBJ_P(zv))

static inline
swig_object_wrapper * php_fetch_object(zend_object *obj) {
  return (swig_object_wrapper *)((char *)obj - XtOffsetOf(swig_object_wrapper, std));
}

#define SWIG_as_voidptr(a) const_cast< void * >(static_cast< const void * >(a))

static void
SWIG_SetPointerZval(zval *z, void *ptr, swig_type_info *type, int newobject) {
  // Return PHP NULL for a C/C++ NULL pointer.
  if (!ptr) {
    ZVAL_NULL(z);
    return;
  }
  if (type->clientdata) {
    if ((newobject & 2) == 0) {
      int resource_type = *(int *)(type->clientdata);
      if (resource_type == 0)
	zend_error(E_ERROR, "Type: %s failed to register with zend", type->name);
      /* Register the pointer as a resource. */
      swig_object_wrapper *value=(swig_object_wrapper *)emalloc(sizeof(swig_object_wrapper));
      value->ptr = ptr;
      value->newobject = (newobject & 1);
      ZVAL_RES(z, zend_register_resource(value, resource_type));
    } else {
      /* This code path is currently only used by directorin typemaps. */
      zend_class_entry *ce = (zend_class_entry*)(type->clientdata);
      zend_object *obj = ce->create_object(ce);
      swig_object_wrapper *value = php_fetch_object(obj);
      value->ptr = ptr;
      value->newobject = (newobject & 1);
      ZVAL_OBJ(z, obj);
    }
    return;
  }
  zend_error(E_ERROR, "Type: %s not registered with zend",type->name);
}

/* This pointer conversion routine takes the native pointer p (along with
   its type name) and converts it by calling appropriate casting functions
   according to ty.  The resultant pointer is returned, or NULL is returned
   if the pointer can't be cast.

   Sadly PHP has no API to find a type name from a type id, only from an
   instance of a resource of the type id, so we have to pass type_name as well.

   The two functions which might call this are:
   SWIG_ConvertResourcePtr which gets the type name from the resource
   and the registered zend destructors for which we have one per type each
   with the type name hard wired in. */
static void *
SWIG_ConvertResourceData(void * p, const char *type_name, swig_type_info *ty) {
  swig_cast_info *tc;
  void *result = 0;

  if (!ty) {
    /* They don't care about the target type, so just pass on the pointer! */
    return p;
  }

  if (! type_name) {
    /* can't convert p to ptr type ty if we don't know what type p is */
    return NULL;
  }

  /* convert and cast p from type_name to ptr as ty. */
  tc = SWIG_TypeCheck(type_name, ty);
  if (tc) {
    int newmemory = 0;
    result = SWIG_TypeCast(tc, p, &newmemory);
    assert(!newmemory); /* newmemory handling not yet implemented */
  }
  return result;
}

/* This function returns a pointer of type ty by extracting the pointer
   and type info from the resource in z.  z must be a resource.
   If it fails, NULL is returned.
   It uses SWIG_ConvertResourceData to do the real work. */
static void *
SWIG_ConvertResourcePtr(zval *z, swig_type_info *ty, int flags) {
  swig_object_wrapper *value;
  void *p;
  const char *type_name;

  if (Z_RES_TYPE_P(z) == -1) return NULL;
  value = (swig_object_wrapper *) Z_RES_VAL_P(z);
  if (flags & SWIG_POINTER_DISOWN) {
    value->newobject = 0;
  }
  p = value->ptr;

  type_name=zend_rsrc_list_get_rsrc_type(Z_RES_P(z));

  return SWIG_ConvertResourceData(p, type_name, ty);
}

/* We allow passing of a RESOURCE wrapping a non-class pointer or an OBJECT
   wrapping a pointer to an object. */
static int
SWIG_ConvertPtr(zval *z, void **ptr, swig_type_info *ty, int flags) {
  if (z == NULL) {
    *ptr = 0;
    return 0;
  }

  switch (Z_TYPE_P(z)) {
    case IS_OBJECT:
      /* FIXME - we need to check the type is compatible here! */
      *ptr = SWIG_Z_FETCH_OBJ_P(z)->ptr;
      return (*ptr == NULL ? -1 : 0);
    case IS_RESOURCE:
      *ptr = SWIG_ConvertResourcePtr(z, ty, flags);
      return (*ptr == NULL ? -1 : 0);
    case IS_NULL:
      *ptr = 0;
      return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }

  return -1;
}

static void
SWIG_SetZval(zval *zv, int newFlow, int newobject, void *ptr, swig_type_info *type, zend_object *std) {
  if (!ptr) {
    ZVAL_NULL(zv);
    return;
  }

  if (newFlow) {
    if (newFlow == 1)
      ZVAL_OBJ(zv,std);
    swig_object_wrapper *obj = SWIG_Z_FETCH_OBJ_P(zv);
    obj->ptr = ptr;
    obj->newobject = newobject;
  } else {
    SWIG_SetPointerZval(zv, ptr, type, newobject);
  }
}

static const char const_name[] = "swig_runtime_data_type_pointer";
static swig_module_info *SWIG_Php_GetModule() {
  zval *pointer = zend_get_constant_str(const_name, sizeof(const_name) - 1);
  if (pointer) {
    if (Z_TYPE_P(pointer) == IS_LONG) {
      return (swig_module_info *) pointer->value.lval;
    }
  }
  return NULL;
}

static void SWIG_Php_SetModule(swig_module_info *pointer, int module_number) {
  REGISTER_LONG_CONSTANT(const_name, (long) pointer, CONST_CS | CONST_PERSISTENT);
}
