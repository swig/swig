/* rubydef.swg */
#ifdef __cplusplus
extern "C" {
#endif

static VALUE _mSWIG = Qnil;
static VALUE _cSWIG_Pointer = Qnil;

/* Initialize Ruby runtime support */
SWIGRUNTIME(void)
SWIG_InitRuntime(void)
{
    if (_mSWIG == Qnil) {
        _mSWIG = rb_define_module("SWIG");
    }
}

/* Define Ruby class for C type */
SWIGRUNTIME(void)
SWIG_define_class(swig_type_info *type)
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
SWIGRUNTIME(VALUE)
SWIG_NewPointerObj(void *ptr, swig_type_info *type, int own)
{
    char *klass_name;
    swig_class *sklass;
    VALUE klass;
    VALUE obj;
    
    if (!ptr)
	return Qnil;
    
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
    return obj;
}

/* Create a new class instance (always owned) */
SWIGRUNTIME(VALUE)
SWIG_NewClassInstance(VALUE klass, swig_type_info *type)
{
    VALUE obj;
    swig_class *sklass = (swig_class *) type->clientdata;
    obj = Data_Wrap_Struct(klass, VOIDFUNC(sklass->mark), VOIDFUNC(sklass->destroy), 0);
    rb_iv_set(obj, "__swigtype__", rb_str_new2(type->name));
    return obj;
}

/* Get type mangle from class name */
SWIGRUNTIME(char *)
SWIG_MangleStr(VALUE obj)
{
  VALUE stype = rb_iv_get(obj, "__swigtype__");
  return StringValuePtr(stype);
}

/* Convert a pointer value */
SWIGRUNTIME(int)
SWIG_ConvertPtr(VALUE obj, void **ptr, swig_type_info *ty, int flags)
{
  char *c;
  swig_type_info *tc;

  /* Grab the pointer */
  if (NIL_P(obj)) {
    *ptr = 0;
    return 0;
  } else {
    Data_Get_Struct(obj, void, *ptr);
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

/* Check convert */
SWIGRUNTIME(int)
SWIG_CheckConvert(VALUE obj, swig_type_info *ty)
{
  char *c = SWIG_MangleStr(obj);
  if (!c)
    return 0;
  return SWIG_TypeCheck(c,ty) != 0;
}

/* Pack binary data into a string */
SWIGRUNTIME(char *)
SWIG_PackData(char *c, void *ptr, int sz) {
  static char hex[17] = "0123456789abcdef";
  int i;
  unsigned char *u = (unsigned char *) ptr;
  register unsigned char uu;
  for (i = 0; i < sz; i++,u++) {
    uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}

/* Unpack binary data from a string */
SWIGRUNTIME(char *)
SWIG_UnpackData(char *c, void *ptr, int sz) {
  register unsigned char uu = 0;
  register int d;
  unsigned char *u = (unsigned char *) ptr;
  int i;
  for (i = 0; i < sz; i++, u++) {
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    *u = uu;
  }
  return c;
}

SWIGRUNTIME(VALUE)
SWIG_NewPackedObj(void *ptr, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(type->name)) > 1000) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r, ptr, sz);
  strcpy(r, type->name);
  return rb_str_new2(result);
}

/* Convert a packed value value */
SWIGRUNTIME(void)
SWIG_ConvertPacked(VALUE obj, void *ptr, int sz, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  char  *c;

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

#ifdef __cplusplus
}
#endif

