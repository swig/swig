/* rubydef.swg */
#ifdef __cplusplus
extern "C" {
#endif


static VALUE _mSWIG = Qnil;
static VALUE _cSWIG_Pointer = Qnil;

/* Define ruby class for C type */
SWIGRUNTIME(void)
SWIG_define_class(swig_type_info *type)
{
    VALUE klass;
    char *klass_name = ALLOCA_N(char, 4 + strlen(type->name) + 1);

    sprintf(klass_name, "TYPE%s", type->name);
    if (NIL_P(_cSWIG_Pointer)) {
	_cSWIG_Pointer = rb_define_class_under(_mSWIG, "Pointer", rb_cObject);
	rb_undef_method(CLASS_OF(_cSWIG_Pointer), "new");
    }
    klass = rb_define_class_under(_mSWIG, klass_name, _cSWIG_Pointer);
}

/* Create a new pointer object */
SWIGRUNTIME(VALUE)
SWIG_NewPointerObj(void *ptr, swig_type_info *type)
{
    char *klass_name;
    VALUE klass;

    if (!ptr)
	return Qnil;

    klass_name = ALLOCA_N(char, 4 + strlen(type->name) + 1);
    sprintf(klass_name, "TYPE%s", type->name);
    klass = rb_const_get(_mSWIG, rb_intern(klass_name));
    return Data_Wrap_Struct(klass, 0, 0, ptr);
}

/* Get type mangle from class name */
SWIGRUNTIME(char *)
SWIG_MangleStr(VALUE obj)
{
  char *c;

  if (!rb_obj_is_kind_of(obj, _cSWIG_Pointer))
    return 0;

  c = rb_class2name(rb_class_of(obj));
  c += strlen(c);
  while (*(--c) != ':');
  /* skip ":TYPE" */
  c += 5;
  return c;
}

/* Convert a pointer value */
SWIGRUNTIME(void *)
SWIG_ConvertPtr(VALUE obj, swig_type_info *ty)
{
  char *c;
  void *ptr;
  swig_type_info *tc;

  if ((c = SWIG_MangleStr(obj)) == NULL)
    rb_raise(rb_eTypeError, "Expected %s", ty->str);	
  Data_Get_Struct(obj, void, ptr);
  if (ty) {
    tc = SWIG_TypeCheck(c, ty);
    if (!tc) rb_raise(rb_eTypeError, "Expected %s", ty->str);
    ptr = SWIG_TypeCast(tc, ptr);
  }
  return ptr;
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

#ifdef __cplusplus
}
#endif

