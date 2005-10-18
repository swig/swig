%include <typemaps/primtypes.swg>

/* Macro for 'signed long' derived types */

%define %type_slong(Type, Frag, Min, Max)
%derived_type_from(long, Type)
%signed_derived_type_asval(long, Type, Frag, Min, Max)
%enddef

/* Macro for 'unsigned long' derived types */

%define %type_ulong(Type, Frag, Max)
%derived_type_from(unsigned long, Type)
%unsigned_derived_type_asval(unsigned long, Type, Frag, Max)
%enddef

/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

%fragment("SWIG_ruby_failed","header")
{
SWIGINTERN VALUE
SWIG_ruby_failed()
{
  return Qnil;
}
 
}


/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE VALUE
  SWIG_From_dec(bool)(bool value)
{
  return value ? Qtrue : Qfalse;
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
	  fragment=SWIG_AsVal_frag(int)) {
SWIGINTERN int
SWIG_AsVal_dec(bool)(VALUE obj, bool *val)
{
  if (obj == Qtrue) {
    if (val) *val = true;
    return SWIG_OK;
  } else if (obj == Qfalse) {
    if (val) *val = false;
    return SWIG_OK;
  } else {
    int res = 0;
    if (SWIG_AsVal(int)(obj, &res) == SWIG_OK) {    
      if (val) *val = res ? true : false;
      return SWIG_OK;
    }
  }  
  return SWIG_TypeError;
}
}

/* signed/unsigned char */

%type_slong(signed char,     "<limits.h>", SCHAR_MIN, SCHAR_MAX)
%type_ulong(unsigned char,   "<limits.h>", UCHAR_MAX)

/* short/unsigned short */

%type_slong(short,           "<limits.h>", SHRT_MIN, SHRT_MAX)
%type_ulong(unsigned short,  "<limits.h>", USHRT_MAX)

/* int/unsigned int */

%type_slong(int,             "<limits.h>", INT_MIN, INT_MAX)
%type_ulong(unsigned int,    "<limits.h>", UINT_MAX)

/* signed/unsigned wchar_t */

#ifdef __cplusplus
%type_slong(signed wchar_t,   "<wchar.h>", WCHAR_MIN, WCHAR_MAX)
%type_ulong(unsigned wchar_t, "<wchar.h>", UWCHAR_MAX)
#endif

/* long */

%fragment(SWIG_From_frag(long),"header",
	  fragment="<limits.h>") {
  SWIG_define(SWIG_From_dec(long),           LONG2NUM)
}

%fragment(SWIG_AsVal_frag(long),"header",fragment="SWIG_ruby_failed") {
SWIGINTERN VALUE SWIG_num2long(VALUE *args)
{
  *((long *)(args[1])) = NUM2LONG(args[0]);
  return args[0];
}  
SWIGINTERN int
SWIG_AsVal_dec(long)(VALUE obj, long* val)
{
  if (obj != Qnil && ((TYPE(obj) == T_FIXNUM) || (TYPE(obj) == T_BIGNUM))) {
    long v;
    VALUE a[2] = { obj, (VALUE)(&v) };
    if (rb_rescue(RUBY_METHOD_FUNC(SWIG_num2long), (VALUE)a, RUBY_METHOD_FUNC(SWIG_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
	  fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE VALUE
SWIG_From_dec(unsigned long)(unsigned long value)
{
  return ULONG2NUM(value); 
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",fragment="SWIG_ruby_failed") {
SWIGINTERN VALUE SWIG_num2ulong(VALUE *args)
{
  *((unsigned long *)(args[1])) = NUM2ULONG(args[0]);
  return args[0];
}
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(VALUE obj, unsigned long *val) 
{
  if (obj != Qnil && ((TYPE(obj) == T_FIXNUM) || (TYPE(obj) == T_BIGNUM))) {
    unsigned long v;
    VALUE a[2] = { obj, (VALUE)(&v) };
    if (rb_rescue(RUBY_METHOD_FUNC(SWIG_num2ulong), (VALUE)a, RUBY_METHOD_FUNC(SWIG_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

/* long long */

%fragment(SWIG_From_frag(long long),"header",
	  fragment=SWIG_From_frag(long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE VALUE 
SWIG_From_dec(long long)(long long value)
{
  return LL2NUM(value);
}
}

%fragment(SWIG_AsVal_frag(long long),"header",fragment="SWIG_ruby_failed") {
SWIGINTERN VALUE SWIG_num2longlong(VALUE *args)
{
  *((long long *)(args[1])) = NUM2LL(args[0]);
  return args[0];
}
SWIGINTERN int
SWIG_AsVal_dec(long long)(VALUE obj, long long *val)
{
  if (obj != Qnil && ((TYPE(obj) == T_FIXNUM) || (TYPE(obj) == T_BIGNUM))) {
    long long v;
    VALUE a[2] = { obj, (VALUE)(&v) };
    if (rb_rescue(RUBY_METHOD_FUNC(SWIG_num2longlong), (VALUE)a, RUBY_METHOD_FUNC(SWIG_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

/* unsigned long long */

%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment=SWIG_From_frag(long long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE VALUE 
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  return ULL2NUM(value);
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",fragment="SWIG_ruby_failed") {
SWIGINTERN VALUE SWIG_num2ulonglong(VALUE *args)
{
  *((unsigned long long *)(args[1])) = NUM2ULL(args[0]);
  return args[0];
}
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(VALUE obj, unsigned long long *val)
{
  if (obj != Qnil && ((TYPE(obj) == T_FIXNUM) || (TYPE(obj) == T_BIGNUM))) {
    unsigned long long v;
    VALUE a[2] = { obj, (VALUE)(&v) };
    if (rb_rescue(RUBY_METHOD_FUNC(SWIG_num2ulonglong), (VALUE)a, RUBY_METHOD_FUNC(SWIG_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

/* float */

%derived_type_from(double, float)
%signed_derived_type_asval(double, float, "<float.h>", -FLT_MAX, FLT_MAX)

/* double */

%fragment(SWIG_From_frag(double),"header") {
  SWIG_define(SWIG_From_dec(double),  rb_float_new)
}

%fragment(SWIG_AsVal_frag(double),"header",fragment="SWIG_ruby_failed") {
SWIGINTERN VALUE SWIG_num2dbl(VALUE *args)
{
  *((double *)(args[1])) = NUM2DBL(args[0]);
  return args[0];
}
SWIGINTERN int
SWIG_AsVal_dec(double)(VALUE obj, double *val)
{
  if (obj != Qnil &&((TYPE(obj) == T_FLOAT) || (TYPE(obj) == T_FIXNUM) || (TYPE(obj) == T_BIGNUM))) {
    double v;
    VALUE a[2] = { obj, (VALUE)(&v) };
    if (rb_rescue(RUBY_METHOD_FUNC(SWIG_num2dbl), (VALUE)a, RUBY_METHOD_FUNC(SWIG_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

/* char */

%fragment(SWIG_From_frag(char),"header") {
SWIGINTERNINLINE VALUE
SWIG_From_dec(char)(char c) 
{ 
  return rb_str_new(&c,1);
}
}

%fragment(SWIG_AsVal_frag(char),"header",
	  fragment="SWIG_AsCharArray",
	  fragment=SWIG_AsVal_frag(signed char)) {
SWIGINTERN int
SWIG_AsVal_dec(char)(VALUE obj, char *val)
{
  signed char v;
  if (SWIG_AsVal(signed char)(obj, &v) == SWIG_OK) {
    if (val) *val = (char)(v);
    return SWIG_OK;
  } else {
    if (SWIG_AsCharArray(obj, val, 1) == SWIG_OK) {
      return SWIG_OK;
    }
  }  
  return SWIG_TypeError;
 }
}

/* wchar_t */


%fragment(SWIG_From_frag(wchar_t),"header",
	  fragment=SWIG_From_frag(char),
	  fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE VALUE
SWIG_From_dec(wchar_t)(wchar_t c) 
{ 
  if (CHAR_MIN <= v && v <= CHAR_MAX) {
    return SWIG_From(char)((char)c);
  } else {
    return SWIG_From(long)((long)c);
  }
}
}

%fragment(SWIG_AsVal_frag(wchar_t),"header",
	  fragment="SWIG_AsWCharArray",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
SWIG_AsVal_dec(wchar_t)(VALUE obj, wchar_t *val)
{
  char v;
  if (SWIG_AsVal(char)(obj, &v) == SWIG_OK) {
    if (val) *val = (wchar_t)(v);
    return SWIG_OK;
  } else {
    long v;
    if (SWIG_AsVal(long)(obj, &v) == SWIG_OK) {
      if (WCHAR_MIN <= v && v <= WCHAR_MAX) {
	if (val) *val = (wchar_t)(v);
	return SWIG_OK;
      }
    }
  }
  return SWIG_TypeError;
}
}

/* ------------------------------------------------------------
 * Apply the primitive typemap for all the types with checkcode
 * ------------------------------------------------------------ */

%apply_checkctypes(%typemap_primitive)
