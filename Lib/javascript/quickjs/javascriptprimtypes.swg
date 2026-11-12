/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE
JSValue SWIG_From_dec(bool)(bool value)
{
  return JS_NewBool(ctx, (JS_BOOL)value);
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
          fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN
int SWIG_AsVal_dec(bool)(JSValue obj, bool *val)
{
  int v;
  if (!JS_IsBool(obj)) {
    return SWIG_ERROR;
  }
  v = JS_ToBool(ctx, obj);
  if (v < 0)
    return SWIG_ERROR;
  if (val) *val = (bool)v;
  return SWIG_OK;
}
}

/* int */

%fragment(SWIG_From_frag(int),"header") {
SWIGINTERNINLINE JSValue
  SWIG_From_dec(int)(int value)
{
  return JS_NewInt32(ctx, value);
}
}

/* long */

%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE JSValue
SWIG_From_dec(long)(long value)
{
%#if defined(LLONG_MAX) && (LONG_MAX == LLONG_MAX)
  return JS_NewInt64(ctx, value);
%#else
  return JS_NewInt32(ctx, value);
%#endif
}
}

%fragment(SWIG_AsVal_frag(long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(long)(JSValueConst obj, long* val)
{
%#if defined(LLONG_MAX) && (LONG_WIDTH == LLONG_WIDTH)
  int64_t v;
  if (!(JS_IsNumber(obj) || JS_IsBigInt(ctx, obj))) {
    return SWIG_TypeError;
  }
%#else
  int32_t v;
  if (!JS_IsNumber(obj)) {
    return SWIG_TypeError;
  }
%#endif
  if (val) {
%#if defined(LLONG_MAX) && (LONG_WIDTH == LLONG_WIDTH)
    if (JS_ToInt64Ext(ctx, &v, obj))
%#else
    if (JS_ToInt32(ctx, &v, obj))
%#endif
      return SWIG_ERROR;
    *val = (long)v;
  }

  return SWIG_OK;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
          fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE JSValue
SWIG_From_dec(unsigned long)(unsigned long value)
{
%#if defined(LLONG_MAX) && (LONG_WIDTH == LLONG_WIDTH)
  return JS_NewInt64(ctx, value);
%#else
  return JS_NewUint32(ctx, value);
%#endif
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(JSValueConst obj, unsigned long *val)
{
%#if defined(LLONG_MAX) && (LONG_WIDTH == LLONG_WIDTH)
  int64_t v;
  if (!(JS_IsNumber(obj) || JS_IsBigInt(ctx, obj))) {
    return SWIG_TypeError;
  }
%#else
  uint32_t v;
  if (!JS_IsNumber(obj)) {
    return SWIG_TypeError;
  }
%#endif

  if (val) {
%#if defined(LLONG_MAX) && (LONG_WIDTH == LLONG_WIDTH)
    if (JS_ToInt64Ext(ctx, &v, obj))
      return SWIG_ERROR;
    if (v<0)
      return SWIG_OverflowError;
%#else
    if (JS_ToUint32(ctx, &v, obj))
      return SWIG_ERROR;
%#endif
    *val = (unsigned long)v;
  }

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
  return JS_NewInt64(ctx, value);
}
%#endif
}

%fragment(SWIG_AsVal_frag(long long),"header",
    fragment=SWIG_AsVal_frag(long),
    fragment="SWIG_CanCastAsInteger",
    fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN int
SWIG_AsVal_dec(long long)(JSValueConst obj, long long* val)
{
  int64_t v;
  if (!(JS_IsNumber(obj) || JS_IsBigInt(ctx,obj))) {
    return SWIG_TypeError;
  }
  if (val) {
    if (JS_ToInt64Ext(ctx, &v, obj))
      return SWIG_ERROR;
    *val = (long long)v;
  }
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
  return JS_NewInt64(ctx, (int64_t)value);
}
%#endif
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
    fragment=SWIG_AsVal_frag(unsigned long),
    fragment="SWIG_CanCastAsInteger",
   fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(JSValueConst obj, unsigned long long *val)
{
  int64_t longVal;
  if (!(JS_IsNumber(obj) || JS_IsBigInt(ctx,obj))) {
    return SWIG_TypeError;
  }

  if (JS_ToInt64Ext(ctx, &longVal, obj))
    return SWIG_ERROR;

  if (longVal < 0) {
      return SWIG_OverflowError;
  }

  if (val) *val = (unsigned long long)longVal;

  return SWIG_OK;
}
%#endif
}

/* double */

%fragment(SWIG_From_frag(double),"header") {
SWIGINTERN JSValue
SWIG_From_dec(double) (double val)
{
  return JS_NewFloat64(ctx, val);
}
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(JSValueConst obj, double *val)
{
  if (!JS_IsNumber(obj)) {
    return SWIG_TypeError;
  }
  if (val)
    if (JS_ToFloat64(ctx, val, obj))
      return SWIG_ERROR;

  return SWIG_OK;
}
}
