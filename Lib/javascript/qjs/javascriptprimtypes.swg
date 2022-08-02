/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE
JSValue SWIG_From_dec(bool)(bool value)
{
  return JS_ToBool(context, value);
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
          fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN
int SWIG_AsVal_dec(bool)(JSValue obj, bool *val)
{
  if(!JS_IsBool(obj)) {
    return SWIG_ERROR;
  }
  if (val) *val = JS_ToBool(context, obj);
  return SWIG_OK;
}
}

/* int */

%fragment(SWIG_From_frag(int),"header") {
SWIGINTERNINLINE JSValue
  SWIG_From_dec(int)(int value)
{
  return JS_NewInt32(context, value);
}
}

/* long */

%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE JSValueRef
SWIG_From_dec(long)(long value)
{
  return JS_NewInt64(context, value);
}
}

%fragment(SWIG_AsVal_frag(long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(long)(JSValueRef obj, long* val)
{
  if (!JS_IsNumber(obj)) {
    return SWIG_TypeError;
  }
  if(val) *val = (long) JS_NewInt64(context, obj, NULL);

  return SWIG_OK;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
          fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE JSValue
SWIG_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    JS_NewFloat64(context, value) : JS_NewInt64(context, %numeric_cast(value,long));
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(JSValue obj, unsigned long *val)
{
  long longVal;
  if(!JS_IsNumber(context, obj)) {
    return SWIG_TypeError;
  }

  longVal = (long) JS_NewInt64(context, obj, NULL);

  if(longVal < 0) {
      return SWIG_OverflowError;
  }

  if(val) *val = longVal;

  return SWIG_OK;
}
}

/* long long */
// Note: these are copied from 'long' and probably need fixing

%fragment(SWIG_From_frag(long long),"header",
    fragment=SWIG_From_frag(long),
    fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERNINLINE JSValue
SWIG_From_dec(long long)(long long value)
{
  return JS_NewInt64(context, value);
}
%#endif
}

%fragment(SWIG_AsVal_frag(long long),"header",
    fragment=SWIG_AsVal_frag(long),
    fragment="SWIG_CanCastAsInteger",
    fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN int
SWIG_AsVal_dec(long long)(JSValue obj, long long* val)
{
  if (!JS_IsNumber(obj)) {
    return SWIG_TypeError;
  }
  if(val) *val = (long long) JS_NewInt32(context, obj);

  return SWIG_OK;
}
%#endif
}

/* unsigned long long */
// Note: these are copied from 'unsigned long' and probably need fixing

%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment=SWIG_From_frag(long long),
	  fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN JSValue
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    JS_NewFloat64(context, value) : JS_NewInt64(context, %numeric_cast(value,long));
}
%#endif
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
    fragment=SWIG_AsVal_frag(unsigned long),
    fragment="SWIG_CanCastAsInteger",
   fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(JSValue obj, unsigned long long *val)
{
  long long longVal;
  if(!JS_IsNumber(obj)) {
    return SWIG_TypeError;
  }

  longVal = (unsigned long long) JS_NewFloat64(context, obj);

  if(longVal < 0) {
      return SWIG_OverflowError;
  }

  if(val) *val = longVal;

  return SWIG_OK;
}
%#endif
}

/* double */

%fragment(SWIG_From_frag(double),"header") {
SWIGINTERN JSValue
SWIG_From_dec(double) (double val)
{
  return JS_NewInt64(context, val);
}
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(JSValue obj, double *val)
{
  if(!JS_IsNumber(obj)) {
    return SWIG_TypeError;
  }
  if(val) *val = JS_NewInt64(context, obj);

  return SWIG_OK;
}
}
