/* -----------------------------------------------------------------------------
 * rubyrun.swg
 *
 * This file contains the runtime support for Ruby modules
 * and includes code for managing global variables and pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0

/* for raw pointers */
#define SWIG_ConvertPtr(obj, pptr, type, flags)         SWIG_Ruby_ConvertPtrAndOwn(obj, pptr, type, flags, 0)
#define SWIG_ConvertPtrAndOwn(obj,pptr,type,flags,own)  SWIG_Ruby_ConvertPtrAndOwn(obj, pptr, type, flags, own)
#define SWIG_NewPointerObj(ptr, type, flags)            SWIG_Ruby_NewPointerObj(ptr, type, flags)
#define SWIG_AcquirePtr(ptr, own)                       SWIG_Ruby_AcquirePtr(ptr, own)
#define swig_owntype                                    swig_ruby_owntype

/* for raw packed data */
#define SWIG_ConvertPacked(obj, ptr, sz, ty)            SWIG_Ruby_ConvertPacked(obj, ptr, sz, ty, flags)
#define SWIG_NewPackedObj(ptr, sz, type)                SWIG_Ruby_NewPackedObj(ptr, sz, type)

/* for class or struct pointers */
#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(ptr, type, flags)           SWIG_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_Ruby_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_Ruby_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define SWIG_GetModule(clientdata)                      SWIG_Ruby_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer) 		SWIG_Ruby_SetModule(pointer)


/* Error manipulation */

#define SWIG_ErrorType(code)                            SWIG_Ruby_ErrorType(code)               
#define SWIG_Error(code, msg)            		rb_raise(SWIG_Ruby_ErrorType(code), "%s", msg)
#define SWIG_fail                        		goto fail				 


/* Ruby-specific SWIG API */

#define SWIG_InitRuntime()                              SWIG_Ruby_InitRuntime()              
#define SWIG_define_class(ty)                        	SWIG_Ruby_define_class(ty)
#define SWIG_NewClassInstance(value, ty)             	SWIG_Ruby_NewClassInstance(value, ty)
#define SWIG_MangleStr(value)                        	SWIG_Ruby_MangleStr(value)		  
#define SWIG_CheckConvert(value, ty)                 	SWIG_Ruby_CheckConvert(value, ty)	  

#include "assert.h"

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  VALUE klass;
  VALUE mImpl;
  rb_data_type_t cext_type_foreign;
  rb_data_type_t cext_type_own;
  int trackObjects;
} swig_class;


/* Global pointer used to keep some internal SWIG stuff */
static VALUE _cSWIG_Pointer = Qnil;
static VALUE swig_runtime_data_type_pointer = Qnil;

/* Global IDs used to keep some internal SWIG stuff */
static ID swig_arity_id = 0;
static ID swig_call_id  = 0;
static ID swig_lowerthan_id = 0;

/*
  If your swig extension is to be run within an embedded ruby and has
  director callbacks, you should set -DRUBY_EMBEDDED during compilation.  
  This will reset ruby's stack frame on each entry point from the main 
  program the first time a virtual director function is invoked (in a 
  non-recursive way).
  If this is not done, you run the risk of Ruby trashing the stack.
*/

#ifdef RUBY_EMBEDDED

#  define SWIG_INIT_STACK                            \
      if ( !swig_virtual_calls ) { RUBY_INIT_STACK } \
      ++swig_virtual_calls;
#  define SWIG_RELEASE_STACK --swig_virtual_calls;
#  define Ruby_DirectorTypeMismatchException(x) \
          rb_raise( rb_eTypeError, "%s", x ); return c_result;

      static unsigned int swig_virtual_calls = 0;

#else  /* normal non-embedded extension */

#  define SWIG_INIT_STACK
#  define SWIG_RELEASE_STACK
#  define Ruby_DirectorTypeMismatchException(x) \
          throw Swig::DirectorTypeMismatchException( x );

#endif  /* RUBY_EMBEDDED */


SWIGRUNTIME VALUE 
getExceptionClass(void) {
  static VALUE rubyExceptionClass = Qnil;
  if (rubyExceptionClass == Qnil) {
    rubyExceptionClass = rb_const_get(_mSWIG, rb_intern("Exception"));
  }
  return rubyExceptionClass;
} 

/* This code checks to see if the Ruby object being raised as part
   of an exception inherits from the Ruby class Exception.  If so,
   the object is simply returned.  If not, then a new Ruby exception
   object is created and that will be returned to Ruby.*/
SWIGRUNTIME VALUE
SWIG_Ruby_ExceptionType(swig_type_info *desc, VALUE obj) {
  VALUE exceptionClass = getExceptionClass();
  if (rb_obj_is_kind_of(obj, exceptionClass)) {
    return obj;
  } else {
    return rb_exc_new3(rb_eRuntimeError, rb_obj_as_string(obj));
  }
}

/* Initialize Ruby runtime support */
SWIGRUNTIME void
SWIG_Ruby_InitRuntime(void)
{
  if (_mSWIG == Qnil) {
    _mSWIG = rb_define_module("SWIG");
    swig_call_id  = rb_intern("call");
    swig_arity_id = rb_intern("arity");
    swig_lowerthan_id = rb_intern("<");
  }
}

/* Define Ruby class for C type */
SWIGRUNTIME void
SWIG_Ruby_define_class(swig_type_info *type)
{
  size_t klass_len = 4 + strlen(type->name) + 1;
  char *klass_name = (char *) malloc(klass_len);
  SWIG_snprintf(klass_name, klass_len, "TYPE%s", type->name);
  if (NIL_P(_cSWIG_Pointer)) {
    _cSWIG_Pointer = rb_define_class_under(_mSWIG, "Pointer", rb_cObject);
    rb_undef_method(CLASS_OF(_cSWIG_Pointer), "new");
  }
  rb_undef_alloc_func(rb_define_class_under(_mSWIG, klass_name, _cSWIG_Pointer));
  free((void *) klass_name);
}

static const rb_data_type_t swig_type_type = {
    .wrap_struct_name = "swig_type",
    .function = {
      .dmark = 0,
      .dfree = 0,
      .dsize = 0,
      .dcompact = 0,
      .reserved = 0},
    .parent = 0,
    .data = 0,
    .flags = 0
};

/* Create a new pointer object */
SWIGRUNTIME VALUE
SWIG_Ruby_NewPointerObj(void *ptr, swig_type_info *type, int flags)
{
  int own =  flags & SWIG_POINTER_OWN; 
  int track;
  char *klass_name;
  swig_class *sklass;
  VALUE klass;
  VALUE obj;

  if (!ptr)
    return Qnil;

  assert(type);
  if (type->clientdata) {
    sklass = (swig_class *) type->clientdata;
		
    /* Are we tracking this class and have we already returned this Ruby object? */
    track = sklass->trackObjects;
    if (track) {
      obj = SWIG_RubyInstanceFor(ptr);

      /* Check the object's type and make sure it has the correct type.
        It might not in cases where methods do things like 
        downcast methods. */
      if (obj != Qnil) {
        VALUE value = rb_iv_get(obj, "@__swigtype__");
        const char* type_name = RSTRING_PTR(value);
				
        if (strcmp(type->name, type_name) == 0) {
          return obj;
        }
      }
    }

    /* Create a new Ruby object */
    obj = TypedData_Wrap_Struct(sklass->klass, own ? &sklass->cext_type_own : &sklass->cext_type_foreign, ptr);

    /* If tracking is on for this class then track this object. */
    if (track) {
      SWIG_RubyAddTracking(ptr, obj);
    }
  } else {
    size_t klass_len = 4 + strlen(type->name) + 1;
    klass_name = (char *) malloc(klass_len);
    SWIG_snprintf(klass_name, klass_len, "TYPE%s", type->name);
    klass = rb_const_get(_mSWIG, rb_intern(klass_name));
    free((void *) klass_name);

    obj = TypedData_Wrap_Struct(klass, &swig_type_type, ptr);
  }
  rb_iv_set(obj, "@__swigtype__", rb_str_new2(type->name));

  return obj;
}

/* Create a new class instance (always owned) */
SWIGRUNTIME VALUE
SWIG_Ruby_NewClassInstance(VALUE klass, swig_type_info *type)
{
  VALUE obj;
  swig_class *sklass = (swig_class *) type->clientdata;

  obj = TypedData_Wrap_Struct(klass, &sklass->cext_type_own, 0);
  rb_iv_set(obj, "@__swigtype__", rb_str_new2(type->name));
  return obj;
}

/* Get type mangle from class name */
SWIGRUNTIMEINLINE char *
SWIG_Ruby_MangleStr(VALUE obj)
{
  VALUE stype = rb_iv_get(obj, "@__swigtype__");
  if (NIL_P(stype))
    return NULL;
  return StringValuePtr(stype);
}

struct SWIG_RTypedData {

    /** The part that all ruby objects have in common. */
    struct RBasic basic;

    /** Direct reference to the slots that holds instance variables, if any **/
    VALUE fields_obj;

    /**
     * This is a `const rb_data_type_t *const` value, with the low bits set:
     *
     * 1: Set if object is embedded.
     *
     * This field  stores various  information about how  Ruby should  handle a
     * data.   This roughly  resembles a  Ruby level  class (apart  from method
     * definition etc.)
     */
    VALUE type;

    /** Pointer to the actual C level struct that you want to wrap. */
    void *data;
};


/* Acquire a pointer value */
typedef struct {
  rb_data_type_t *cext_type;
  int own;
} swig_ruby_owntype;

SWIGRUNTIME swig_ruby_owntype
SWIG_Ruby_AcquirePtr(VALUE obj, swig_ruby_owntype own) {
  swig_ruby_owntype oldown = {0, 0};
  if (RB_TYPE_P(obj, RUBY_T_DATA) && RTYPEDDATA_P(obj)) {
    oldown.cext_type = (rb_data_type_t *)RTYPEDDATA_TYPE(obj);
    /* TODO: This is ruby internal */
    ((struct SWIG_RTypedData*)RTYPEDDATA(obj))->type = (RTYPEDDATA(obj)->type & ~TYPED_DATA_PTR_MASK)
          | (VALUE)own.cext_type;
  }
  return oldown;
}

/* Convert a pointer value */
SWIGRUNTIME int
SWIG_Ruby_ConvertPtrAndOwn(VALUE obj, void **ptr, swig_type_info *ty, int flags, swig_ruby_owntype *own)
{
  char *c;
  swig_cast_info *tc;
  void *vptr = 0;

  /* Grab the pointer */
  if (NIL_P(obj)) {
    if (ptr)
      *ptr = 0;
    return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  } else if (RB_TYPE_P(obj, RUBY_T_DATA) && RTYPEDDATA_P(obj)) {
    vptr = RTYPEDDATA_DATA(obj);
  } else {
    return SWIG_ERROR;
  }
  
  if (own) {
    own->cext_type = (rb_data_type_t *)RTYPEDDATA_TYPE(obj);
    own->own = 0;
  }
    
  if (((flags & SWIG_POINTER_RELEASE) == SWIG_POINTER_RELEASE)) {
    if (!RTYPEDDATA_TYPE(obj)->function.dfree)
      return SWIG_ERROR_RELEASE_NOT_OWNED;
  }

  /* Check to see if the input object is giving up ownership
     of the underlying C struct or C++ object.  If so then we
     need to reset the destructor since the Ruby object no 
     longer owns the underlying C++ object.*/ 
  if (flags & SWIG_POINTER_DISOWN) {
    /* Is tracking on for this class? */
    const rb_data_type_t *cext_type = &swig_type_type;
    if (ty && ty->clientdata) {
      swig_class *sklass = (swig_class *) ty->clientdata;
      cext_type = &sklass->cext_type_foreign;
    }

    /* TODO: This is ruby internal */
    ((struct SWIG_RTypedData*)RTYPEDDATA(obj))->type = (RTYPEDDATA(obj)->type & ~TYPED_DATA_PTR_MASK)
          | (VALUE)cext_type;

    // if (track) {
    //   /* We are tracking objects for this class.  Thus we change the destructor
    //    * to SWIG_RubyRemoveTracking.  This allows us to
    //    * remove the mapping from the C++ to Ruby object
    //    * when the Ruby object is garbage collected.  If we don't
    //    * do this, then it is possible we will return a reference
    //    * to a Ruby object that no longer exists thereby crashing Ruby. */
    //   wrobj->dfree = SWIG_RubyRemoveTracking;
    // } else {
    //   wrobj->dfree = 0;
    // }
  }

  if (flags & SWIG_POINTER_CLEAR) {
    DATA_PTR(obj) = 0;
  }

  /* Do type-checking if type info was provided */
  if (ty) {
    if (ty->clientdata) {
      if (rb_obj_is_kind_of(obj, ((swig_class *) (ty->clientdata))->klass)) {
        if (vptr == 0) {
          /* The object has already been deleted */
          return SWIG_ObjectPreviouslyDeletedError;
        }
      }
    }
    if ((c = SWIG_MangleStr(obj)) == NULL) {
      return SWIG_ERROR;
    }
    tc = SWIG_TypeCheck(c, ty);
    if (!tc) {
      return SWIG_ERROR;
    } else {
      if (ptr) {
        if (tc->type == ty) {
          *ptr = vptr;
        } else {
          int newmemory = 0;
          *ptr = SWIG_TypeCast(tc, vptr, &newmemory);
          if (newmemory == SWIG_CAST_NEW_MEMORY) {
            assert(own); /* badly formed typemap which will lead to a memory leak - it must set and use own to delete *ptr */
            if (own)
              own->own = own->own | SWIG_CAST_NEW_MEMORY;
          }
        }
      }
    }
  } else {
    if (ptr)
      *ptr = vptr;
  }
  
  return SWIG_OK;
}

/* Check convert */
SWIGRUNTIMEINLINE int
SWIG_Ruby_CheckConvert(VALUE obj, swig_type_info *ty)
{
  char *c = SWIG_MangleStr(obj);
  if (!c) return 0;
  return SWIG_TypeCheck(c,ty) != 0;
}

SWIGRUNTIME VALUE
SWIG_Ruby_NewPackedObj(void *ptr, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(type->name)) > 1000) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r, ptr, sz);
  strcpy(r, type->name);
  return rb_str_new2(result);
}

/* Convert a packed pointer value */
SWIGRUNTIME int
SWIG_Ruby_ConvertPacked(VALUE obj, void *ptr, int sz, swig_type_info *ty) {
  swig_cast_info *tc;
  const char  *c;

  if (TYPE(obj) != T_STRING) goto type_error;
  c = StringValuePtr(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') goto type_error;
  c++;
  c = SWIG_UnpackData(c, ptr, sz);
  if (ty) {
    tc = SWIG_TypeCheck(c, ty);
    if (!tc) goto type_error;
  }
  return SWIG_OK;

 type_error:
  return SWIG_ERROR;
}


static const rb_data_type_t swig_runtime_data_type = {
    .wrap_struct_name = "swig_runtime_data" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME,
    .function = {
      .dmark = 0,
      .dfree = 0,
      .dsize = 0,
      .dcompact = 0,
      .reserved = 0},
    .parent = 0,
    .data = 0,
    .flags = 0
};

SWIGRUNTIME swig_module_info *
SWIG_Ruby_GetModule(void *SWIGUNUSEDPARM(clientdata))
{
  VALUE pointer;
  swig_module_info *ret = 0;
  VALUE verbose = rb_gv_get("VERBOSE");

 /* temporarily disable warnings, since the pointer check causes warnings with 'ruby -w' */
  rb_gv_set("VERBOSE", Qfalse);

  /* first check if pointer already created */
  pointer = rb_gv_get("$swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME);
  if (pointer != Qnil) {
    /* Can not use TypedData_Get_Struct because swig_runtime_data_type is not global, but once per file. */
    if (!RB_TYPE_P(pointer, RUBY_T_DATA)) rb_check_typeddata(pointer, &swig_runtime_data_type);
    ret = (swig_module_info *)DATA_PTR(pointer);
  }

  /* reinstate warnings */
  rb_gv_set("VERBOSE", verbose);
  return ret;
}

SWIGRUNTIME void 
SWIG_Ruby_SetModule(swig_module_info *pointer)
{
  /* register a new class */
  VALUE cl = rb_define_class("swig_runtime_data", rb_cObject);
  rb_undef_alloc_func(cl);
  /* create and store the structure pointer to a global variable */
  swig_runtime_data_type_pointer = TypedData_Wrap_Struct(cl, &swig_runtime_data_type, pointer);
  rb_define_readonly_variable("$swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, &swig_runtime_data_type_pointer);
}

/* This function can be used to check whether a proc or method or similarly
   callable function has been passed.  Usually used in a %typecheck, like:

   %typecheck(c_callback_t, precedence=SWIG_TYPECHECK_POINTER) {
        $result = SWIG_Ruby_isCallable( $input );
   }
 */
SWIGINTERN
int SWIG_Ruby_isCallable( VALUE proc )
{
  if ( rb_respond_to( proc, swig_call_id ) )
    return 1;
  return 0;
}

/* This function can be used to check the arity (number of arguments)
   a proc or method can take.  Usually used in a %typecheck.
   Valid arities will be that equal to minimal or those < 0
   which indicate a variable number of parameters at the end.
 */
SWIGINTERN
int SWIG_Ruby_arity( VALUE proc, int minimal )
{
  if ( rb_respond_to( proc, swig_arity_id ) )
    {
      VALUE num = rb_funcall2( proc, swig_arity_id, 0, 0 );
      int arity = NUM2INT(num);
      if ( arity < 0 && (arity+1) < -minimal ) return 1;
      if ( arity == minimal ) return 1;
      return 1;
    }
  return 0;
}


#ifdef __cplusplus
}
#endif
