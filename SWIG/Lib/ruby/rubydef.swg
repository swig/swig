/* Common SWIG API */
#define SWIG_ConvertPtr(obj, pp, type, flags) \
  SWIG_Ruby_ConvertPtr(obj, pp, type, flags)
#define SWIG_NewPointerObj(p, type, flags) \
  SWIG_Ruby_NewPointerObj(p, type, flags)
#define SWIG_MustGetPtr(p, type, argnum, flags) \
  SWIG_Ruby_MustGetPtr(p, type, argnum, flags)
#define SWIG_GetModule(clientdata) \
  SWIG_Ruby_GetModule()
#define SWIG_SetModule(clientdata, pointer) \
  SWIG_Ruby_SetModule(pointer)

/* Ruby-specific SWIG API */

#define SWIG_InitRuntime() \
  SWIG_Ruby_InitRuntime()
#define SWIG_define_class(ty) \
  SWIG_Ruby_define_class(ty)
#define SWIG_NewClassInstance(value, ty) \
  SWIG_Ruby_NewClassInstance(value, ty)
#define SWIG_MangleStr(value) \
  SWIG_Ruby_MangleStr(value)
#define SWIG_CheckConvert(value, ty) \
  SWIG_Ruby_CheckConvert(value, ty)
#define SWIG_NewPackedObj(ptr, sz, ty) \
  SWIG_Ruby_NewPackedObj(ptr, sz, ty)
#define SWIG_ConvertPacked(obj, ptr, sz, ty, flags) \
  SWIG_Ruby_ConvertPacked(obj, ptr, sz, ty, flags)

/* rubydef.swg */
#ifdef __cplusplus
extern "C" {
#endif

static VALUE _mSWIG = Qnil;
static VALUE _cSWIG_Pointer = Qnil;
static VALUE swig_runtime_data_type_pointer = Qnil;

/* Initialize Ruby runtime support */
static void
SWIG_Ruby_InitRuntime(void)
{
    if (_mSWIG == Qnil) {
        _mSWIG = rb_define_module("SWIG");
    }
}

/* Define Ruby class for C type */
static void
SWIG_Ruby_define_class(swig_type_info *type)
{
    VALUE klass;
    char *klass_name = (char *) malloc(4 + strlen(type->name) + 1);
    sprintf(klass_name, "TYPE%s", type->name);
    if (NIL_P(_cSWIG_Pointer)) {
	_cSWIG_Pointer = rb_define_class_under(_mSWIG, "Pointer", rb_cObject);
	rb_undef_method(CLASS_OF(_cSWIG_Pointer), "new");
    }
    klass = rb_define_class_under(_mSWIG, klass_name, _cSWIG_Pointer);
    free((void *) klass_name);
}

/* Create a new pointer object */
static VALUE
SWIG_Ruby_NewPointerObj(void *ptr, swig_type_info *type, int flags)
{
	 int own = flags & SWIG_POINTER_OWN;
	 int track = flags & SWIG_TRACK_OBJECTS;
	 
    char *klass_name;
    swig_class *sklass;
    VALUE klass;
    VALUE obj;
    
    if (!ptr)
      return Qnil;
    
    /* Have we already wrapped this pointer? */
    if (track) {
	    obj = SWIG_RubyInstanceFor(ptr);
   	 if (obj != Qnil) {
      	return obj;
    	}
    }
		
    if (type->clientdata) {
      sklass = (swig_class *) type->clientdata;
      obj = Data_Wrap_Struct(sklass->klass, VOIDFUNC(sklass->mark), (own ? VOIDFUNC(sklass->destroy) : 0), ptr);
    } else {
      klass_name = (char *) malloc(4 + strlen(type->name) + 1);
      sprintf(klass_name, "TYPE%s", type->name);
      klass = rb_const_get(_mSWIG, rb_intern(klass_name));
      free((void *) klass_name);
      obj = Data_Wrap_Struct(klass, 0, 0, ptr);
    }
    rb_iv_set(obj, "__swigtype__", rb_str_new2(type->name));
    
    /* Keep track of this object if necessary */
    if (track) {
	   SWIG_RubyAddTracking(ptr, obj);
    }
   
    return obj;
}

/* Create a new class instance (always owned) */
static VALUE
SWIG_Ruby_NewClassInstance(VALUE klass, swig_type_info *type)
{
    VALUE obj;
    swig_class *sklass = (swig_class *) type->clientdata;
    obj = Data_Wrap_Struct(klass, VOIDFUNC(sklass->mark), VOIDFUNC(sklass->destroy), 0);
    rb_iv_set(obj, "__swigtype__", rb_str_new2(type->name));
    return obj;
}

/* Get type mangle from class name */
static SWIGINLINE char *
SWIG_Ruby_MangleStr(VALUE obj)
{
  VALUE stype = rb_iv_get(obj, "__swigtype__");
  return StringValuePtr(stype);
}

/* Convert a pointer value */
static int
SWIG_Ruby_ConvertPtr(VALUE obj, void **ptr, swig_type_info *ty, int flags)
{
  char *c;
  swig_cast_info *tc;

  /* Grab the pointer */
  if (NIL_P(obj)) {
    *ptr = 0;
    return 0;
  } else {
    Data_Get_Struct(obj, void, *ptr);
  }
  
  /* Check to see if the input object is giving up ownership
     of the underlying C struct or C++ object.  If so then we
     need to reset the destructor since the Ruby object no 
     longer owns the underlying C++ object.*/ 
  if (flags & SWIG_POINTER_DISOWN) {
	 if (flags & SWIG_TRACK_OBJECTS) {
      /* We are tracking objects.  Thus we change the destructor
		 * to SWIG_RubyRemoveTracking.  This allows us to
		 * remove the mapping from the C++ to Ruby object
		 * when the Ruby object is garbage collected.  If we don't
		 * do this, then it is possible we will return a reference 
		 * to a Ruby object that no longer exists thereby crashing Ruby. */
		RDATA(obj)->dfree = SWIG_RubyRemoveTracking;
  	 } else {    
      RDATA(obj)->dfree = 0;
    }
  }

  /* Do type-checking if type info was provided */
  if (ty) {
    if (ty->clientdata) {
        if (rb_obj_is_kind_of(obj, ((swig_class *) (ty->clientdata))->klass)) {
          if (*ptr == 0)
            rb_raise(rb_eRuntimeError, "This %s already released", ty->str);
          return 0;
        }
    }
    if ((c = SWIG_MangleStr(obj)) == NULL) {
      if (flags & SWIG_POINTER_EXCEPTION)
        rb_raise(rb_eTypeError, "Expected %s", ty->str);
      else
        return -1;
    }
    tc = SWIG_TypeCheck(c, ty);
    if (!tc) {
      if (flags & SWIG_POINTER_EXCEPTION)
        rb_raise(rb_eTypeError, "Expected %s", ty->str);
      else
        return -1;
    }
    *ptr = SWIG_TypeCast(tc, *ptr);
  }
  return 0;
}

/* Convert a pointer value, signal an exception on a type mismatch */
static SWIGINLINE void *
SWIG_Ruby_MustGetPtr(VALUE obj, swig_type_info *ty, int argnum, int flags)
{
  void *result;
  SWIG_ConvertPtr(obj, &result, ty, flags | SWIG_POINTER_EXCEPTION);
  return result;
}

/* Check convert */
static SWIGINLINE int
SWIG_Ruby_CheckConvert(VALUE obj, swig_type_info *ty)
{
  char *c = SWIG_MangleStr(obj);
  if (!c)
    return 0;
  return SWIG_TypeCheck(c,ty) != 0;
}

static VALUE
SWIG_Ruby_NewPackedObj(void *ptr, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(type->name)) > 1000) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r, ptr, sz);
  strcpy(r, type->name);
  return rb_str_new2(result);
}

/* Convert a packed value value */
static void
SWIG_Ruby_ConvertPacked(VALUE obj, void *ptr, int sz, swig_type_info *ty, int flags) {
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
  return;

type_error:

  if (flags) {
    if (ty) {
      rb_raise(rb_eTypeError, "Type error. Expected %s", ty->name);
    } else {
      rb_raise(rb_eTypeError, "Expected a pointer");
    }
  }
}

static swig_module_info *SWIG_Ruby_GetModule() {
    VALUE pointer;
    swig_module_info *ret = 0;

   /* first check if pointer already created */
    pointer = rb_gv_get("$swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME);
    if (pointer != Qnil) {
      Data_Get_Struct(pointer, swig_module_info, ret);
    }
    return ret;
}

static void SWIG_Ruby_SetModule(swig_module_info *pointer) {
      /* register a new class */
      VALUE cl = rb_define_class("swig_runtime_data", rb_cObject);
      /* create and store the structure pointer to a global variable */
      swig_runtime_data_type_pointer = Data_Wrap_Struct(cl, 0, 0, pointer);
      rb_define_readonly_variable("$swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, &swig_runtime_data_type_pointer);
}

#ifdef __cplusplus
}
#endif

