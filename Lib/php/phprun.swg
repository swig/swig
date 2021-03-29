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

#define SWIG_as_voidptr(a) const_cast< void * >(static_cast< const void * >(a))

static void
SWIG_SetPointerZval(zval *z, void *ptr, swig_type_info *type, int newobject) {
  /*
   * First test for Null pointers.  Return those as PHP native NULL
   */
  if (!ptr ) {
    ZVAL_NULL(z);
    return;
  }
  if (type->clientdata) {
    swig_object_wrapper *value;
    if (! (*(int *)(type->clientdata)))
      zend_error(E_ERROR, "Type: %s failed to register with zend",type->name);
    value=(swig_object_wrapper *)emalloc(sizeof(swig_object_wrapper));
    value->ptr=ptr;
    value->newobject=(newobject & 1);
    if ((newobject & 2) == 0) {
      /* Just register the pointer as a resource. */
      ZVAL_RES(z, zend_register_resource(value, *(int *)(type->clientdata)));
    } else {
      /*
       * Wrap the resource in an object, the resource will be accessible
       * via the "_cPtr" property. This code path is currently only used by
       * directorin typemaps.
       */
      zend_class_entry *ce = NULL;
      const char *type_name = type->name+3; /* +3 so: _p_Foo -> Foo */
      size_t type_name_len;
      const char * p;

      /* Namespace__Foo -> Foo */
      /* FIXME: ugly and goes wrong for classes with __ in their names. */
      while ((p = strstr(type_name, "__")) != NULL) {
        type_name = p + 2;
      }
      type_name_len = strlen(type_name);

      if (SWIG_PREFIX_LEN > 0) {
        zend_string * classname = zend_string_alloc(SWIG_PREFIX_LEN + type_name_len, 0);
        memcpy(ZSTR_VAL(classname), SWIG_PREFIX, SWIG_PREFIX_LEN);
        memcpy(ZSTR_VAL(classname) + SWIG_PREFIX_LEN, type_name, type_name_len);
        ce = zend_lookup_class(classname);
        zend_string_release(classname);
      } else {
        zend_string * classname = zend_string_init(type_name, type_name_len, 0);
        ce = zend_lookup_class(classname);
        zend_string_release(classname);
      }
      if (ce == NULL) {
        /* class does not exist */
        object_init(z);
      } else {
        object_init_ex(z, ce);
      }

      add_property_resource_ex(z, "_cPtr", sizeof("_cPtr") - 1, zend_register_resource(value, *(int *)(type->clientdata)));
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

  if (!type_name) {
    if (Z_TYPE_P(z) == IS_OBJECT) {
#if PHP_MAJOR_VERSION < 8
      HashTable * ht = Z_OBJ_HT_P(z)->get_properties(z);
#else
      HashTable * ht = Z_OBJ_HT_P(z)->get_properties(Z_OBJ_P(z));
#endif
      zval * _cPtr = zend_hash_str_find(ht, "_cPtr", sizeof("_cPtr") - 1);
      type_name=zend_rsrc_list_get_rsrc_type(Z_RES_P(_cPtr));
    }
  }

  return SWIG_ConvertResourceData(p, type_name, ty);
}

#define SWIG_Z_FETCH_OBJ_P(zv) php_fetch_object(Z_OBJ_P(zv))

static inline
swig_object_wrapper * php_fetch_object(zend_object *obj) {
  return (swig_object_wrapper *)((char *)obj - XtOffsetOf(swig_object_wrapper, std));
}

/* We allow passing of a RESOURCE pointing to the object or an OBJECT whose
   _cPtr is a resource pointing to the object */
static int
SWIG_ConvertPtr(zval *z, void **ptr, swig_type_info *ty, int flags) {
  if (z == NULL) {
    *ptr = 0;
    return 0;
  }

  switch (Z_TYPE_P(z)) {
    case IS_OBJECT: {
#if PHP_MAJOR_VERSION < 8
      HashTable * ht = Z_OBJ_HT_P(z)->get_properties(z);
#else
      HashTable * ht = Z_OBJ_HT_P(z)->get_properties(Z_OBJ_P(z));
#endif
      if (ht) {
        zval * _cPtr = zend_hash_str_find(ht, "_cPtr", sizeof("_cPtr") - 1);
        if (_cPtr) {
          if (zend_hash_str_exists(ht, "SWIG_classWrapper", sizeof("SWIG_classWrapper") - 1)) {
            /* FIXME - we need to check the type is compatible here! */
            *ptr = SWIG_Z_FETCH_OBJ_P(z)->ptr;
            return (*ptr == NULL ? -1 : 0);
          }
          if (Z_TYPE_P(_cPtr) == IS_INDIRECT) {
            _cPtr = Z_INDIRECT_P(_cPtr);
          }
          if (Z_TYPE_P(_cPtr) == IS_RESOURCE) {
            *ptr = SWIG_ConvertResourcePtr(_cPtr, ty, flags);
            return (*ptr == NULL ? -1 : 0);
          }
        }
      }
      break;
    }
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
SWIG_pack_zval(zval *zv, void *ptr, int userNewObj) {
  swig_object_wrapper *obj = SWIG_Z_FETCH_OBJ_P(zv);
  obj->ptr = ptr;
  obj->newobject = userNewObj;
}

static void
SWIG_generalize_object(zval *zval_obj, void *ptr, int userNewObj, swig_type_info *type) {
  zval tempZval;
  HashTable *ht = 0;

  SWIG_pack_zval(zval_obj, ptr, userNewObj);
#if PHP_MAJOR_VERSION < 8
  ht = Z_OBJ_HT_P(zval_obj)->get_properties(zval_obj);
#else
  ht = Z_OBJ_HT_P(zval_obj)->get_properties(Z_OBJ_P(zval_obj));
#endif

  if(ht) {
    ZVAL_RES(&tempZval,zend_register_resource(ptr,*(int *)(type->clientdata)));
    zend_hash_str_add(ht, "_cPtr", sizeof("_cPtr") - 1, &tempZval);
    ZVAL_TRUE(&tempZval);
    zend_hash_str_add(ht, "SWIG_classWrapper", sizeof("SWIG_classWrapper") - 1, &tempZval);
  }
}

static void
SWIG_SetZval( zval *zv, int newFlow, int userNewObj, void *ptr, swig_type_info *type, zend_object *std) {

  if (!ptr) {
    ZVAL_NULL(zv);
    return;
  }

  if (newFlow) {
    if (newFlow == 1)
      ZVAL_OBJ(zv,std);
    SWIG_generalize_object(zv, ptr, userNewObj, type);
  }
  else {
    SWIG_SetPointerZval(zv, ptr, type, userNewObj);
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
