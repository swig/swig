/* rubydef.swg */
#ifdef __cplusplus
extern "C" {
#endif


static VALUE _mSWIG = Qnil;
static VALUE _cSWIG_Pointer = Qnil;

/* Define ruby class for C type */
SWIGSTATICRUNTIME(void)
SWIG_define_class(_swig_type_info *type)
{
    char *klass_name = ALLOCA_N(char, 4 + strlen(type->name) + 1);
    sprintf(klass_name, "TYPE%s", type->name);
    if (NIL_P(_cSWIG_Pointer)) {
	_cSWIG_Pointer = rb_define_class_under(_mSWIG, "Pointer", rb_cObject);
    }
    rb_define_class_under(_mSWIG, klass_name, _cSWIG_Pointer);
}

/* Create a new pointer object */
SWIGSTATICRUNTIME(VALUE)
SWIG_NewPointerObj(void *ptr, _swig_type_info *type)
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
SWIGSTATICRUNTIME(char *)
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
SWIGSTATICRUNTIME(void *)
SWIG_ConvertPtr(VALUE obj, _swig_type_info *ty)
{
  char *c;
  void *ptr;
  _swig_type_info *tc;

  if ((c = SWIG_MangleStr(obj)) == NULL)
    rb_raise(rb_eTypeError, "Expected %s", ty->name);	
  Data_Get_Struct(obj, void, ptr);
  if (ty) {
    tc = SWIG_TypeCheck(c, ty);
    if (!tc) rb_raise(rb_eTypeError, "Expected %s", ty->name);
    ptr = SWIG_TypeCast(tc, ptr);
  }
  return ptr;
}

/* Check convert */
SWIGSTATICRUNTIME(int)
SWIG_CheckConvert(VALUE obj, _swig_type_info *ty)
{
  char *c = SWIG_MangleStr(obj);
  if (!c)
    return 0;
  return SWIG_TypeCheck(c,ty) != 0;
}

#ifdef __cplusplus
}
#endif

