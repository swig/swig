/* -----------------------------------------------------------------------------
 * phprun.swg
 *
 * PHP runtime library
 * ----------------------------------------------------------------------------- */

#define swig_owntype                                    int

#ifdef __cplusplus
extern "C" {
#endif

#include "php.h"

#if PHP_MAJOR_VERSION < 7
# error These bindings need PHP 7 or later - to generate PHP5 bindings use: SWIG < 4.0.0 and swig -php5
#endif

#include "zend_inheritance.h"
#include "zend_exceptions.h"
#include "zend_inheritance.h"

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

#define SWIG_PHP_Error(code,msg) do { zend_throw_exception(NULL, msg, code); SWIG_fail; } while (0)

#define SWIG_contract_assert(expr,msg) \
  do { if (!(expr)) zend_printf("Contract Assert Failed %s\n", msg); } while (0)

/* Standard SWIG API */
#define SWIG_GetModule(clientdata) SWIG_Php_GetModule()
#define SWIG_SetModule(clientdata, pointer) SWIG_Php_SetModule(pointer, *(int*)clientdata)

/* used to wrap returned objects in so we know whether they are newobject
   and need freeing, or not */
typedef struct {
  void * ptr;
  int newobject;
  const swig_type_info * type;
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

  if (!type->clientdata) {
    zend_type_error("Type: %s not registered with zend", type->name);
    return;
  }

  {
    zend_object *obj;
    swig_object_wrapper *value;
    if (Z_TYPE_P(z) == IS_OBJECT) {
      /* The PHP object is already initialised - this is the case when wrapping
       * the return value from a PHP constructor. */
      obj = Z_OBJ_P(z);
    } else {
      zend_class_entry *ce = (zend_class_entry*)(type->clientdata);
      obj = ce->create_object(ce);
      ZVAL_OBJ(z, obj);
    }
    value = php_fetch_object(obj);
    value->ptr = ptr;
    value->newobject = (newobject & 1);
    value->type = type;
  }
}

/* This pointer conversion routine takes the native pointer p (along with
   its type name) and converts it by calling appropriate casting functions
   according to ty.  The resultant pointer is returned, or NULL is returned
   if the pointer can't be cast.

   This is called by SWIG_ConvertPtr which gets the type name from the
   swig_object_wrapper. */
static void *
SWIG_ConvertPtrData(void * p, const char *type_name, swig_type_info *ty, int *own) {
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
    if (newmemory == SWIG_CAST_NEW_MEMORY) {
      assert(own); /* badly formed typemap which will lead to a memory leak - it must set and use own to delete *ptr */
      if (own)
        *own |= SWIG_CAST_NEW_MEMORY;
    }
  }
  return result;
}

/* We wrap C/C++ pointers as PHP objects. */
static int
SWIG_ConvertPtrAndOwn(zval *z, void **ptr, swig_type_info *ty, int flags, swig_owntype *own) {
  if (own)
    *own = 0;

  if (z == NULL) {
    *ptr = 0;
    return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }

  switch (Z_TYPE_P(z)) {
    case IS_OBJECT: {
      swig_object_wrapper *value = SWIG_Z_FETCH_OBJ_P(z);
      *ptr = SWIG_ConvertPtrData(value->ptr, value->type->name, ty, own);
      if (*ptr == NULL) return SWIG_ERROR;
      if (flags & SWIG_POINTER_DISOWN) {
	value->newobject = 0;
      }
      return SWIG_OK;
    }
    case IS_NULL:
      *ptr = 0;
      return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }

  return -1;
}

static int
SWIG_ConvertPtr(zval *z, void **ptr, swig_type_info *ty, int flags) {
  return SWIG_ConvertPtrAndOwn(z, ptr, ty, flags, 0);
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
