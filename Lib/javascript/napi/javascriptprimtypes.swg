/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header", "header") {
SWIGINTERN
Napi::Value SWIG_From_bool(Napi::Env env, bool val)
{
  return Napi::Boolean::New(env, val);
}
}


%fragment(SWIG_AsVal_frag(bool),"header",
          fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN
int SWIG_AsVal_dec(bool)(Napi::Value obj, bool *val)
{
  if(!obj.IsBoolean()) {
    return SWIG_TypeError;
  }

  Napi::Boolean b;
  NAPI_CHECK_RESULT(obj.ToBoolean(), b);
  if (val) *val = b.Value();
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}

/* char */

%fragment(SWIG_From_frag(unsigned char), "header") {
SWIGINTERNINLINE Napi::Value
SWIG_From_unsigned_SS_char(Napi::Env env, unsigned char c)
{
  return Napi::Number::New(env, static_cast<double>(c));
}
}


%fragment(SWIG_From_frag(signed char), "header") {
SWIGINTERNINLINE Napi::Value
SWIG_From_signed_SS_char(Napi::Env env, signed char c)
{
  return Napi::Number::New(env, static_cast<double>(c));
}
}

/* int */

%fragment(SWIG_From_frag(int), "header") {
SWIGINTERN
Napi::Value SWIG_From_int(Napi::Env env, int val)
{
  return Napi::Number::New(env, val);
}
}

%fragment(SWIG_AsVal_frag(int),"header") {
SWIGINTERN
int SWIG_AsVal_dec(int)(Napi::Value valRef, int* val)
{
  if (!valRef.IsNumber()) {
    return SWIG_TypeError;
  }
  if (val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(valRef.ToNumber(), num);
    *val = static_cast<int>(num.Int32Value());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}


/* unsigned int */

%fragment(SWIG_From_frag(unsigned int), "header") {
SWIGINTERN
Napi::Value SWIG_From_unsigned_SS_int(Napi::Env env, unsigned int val)
{
  return Napi::Number::New(env, val);
}
}

%fragment(SWIG_AsVal_frag(unsigned int),"header") {
SWIGINTERN
int SWIG_AsVal_dec(unsigned int)(Napi::Value valRef, unsigned int* val)
{
  if (!valRef.IsNumber()) {
    return SWIG_TypeError;
  }
  if (val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(valRef.ToNumber(), num);
    if (num.Int64Value() < 0) {
      return SWIG_TypeError;
    }
    *val = static_cast<unsigned int>(num.Uint32Value());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}


/* short */

%fragment("SWIG_Env_FromShort", "header") {
SWIGINTERN
Napi::Value SWIG_From_short(Napi::Env env, short val)
{
  return Napi::Number::New(env, val);
}
}

%fragment(SWIG_AsVal_frag(short),"header") {
SWIGINTERN
int SWIG_AsVal_dec(short)(Napi::Value valRef, short* val)
{
  if (!valRef.IsNumber()) {
    return SWIG_TypeError;
  }
  if (val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(valRef.ToNumber(), num);
    *val = static_cast<short>(num.Int32Value());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}


/* unsigned short */

%fragment(SWIG_From_frag(unsigned short), "header") {
SWIGINTERN
Napi::Value SWIG_From_unsigned_SS_short(Napi::Env env, unsigned short val)
{
  return Napi::Number::New(env, val);
}
}

%fragment(SWIG_AsVal_frag(unsigned short),"header") {
SWIGINTERN
int SWIG_AsVal_dec(unsigned short)(Napi::Value valRef, unsigned short* val)
{
  if (!valRef.IsNumber()) {
    return SWIG_TypeError;
  }
  if (val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(valRef.ToNumber(), num);
    if (num.Int64Value() < 0) {
      return SWIG_TypeError;
    }
    *val = static_cast<unsigned short>(num.Uint32Value());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}


/* long */

%fragment(SWIG_From_frag(long), "header") {
SWIGINTERN
Napi::Value SWIG_From_long(Napi::Env env, long val)
{
  return Napi::Number::New(env, val);
}
}

%fragment(SWIG_AsVal_frag(long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN
int SWIG_AsVal_dec(long)(Napi::Value obj, long* val)
{
  if (!obj.IsNumber()) {
    return SWIG_TypeError;
  }
  if (val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(obj.ToNumber(), num);
    *val = static_cast<long>(num.Int64Value());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long), "header") {
SWIGINTERN
Napi::Value SWIG_From_unsigned_SS_long(Napi::Env env, unsigned long val)
{
  return Napi::Number::New(env, val);
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN
int SWIG_AsVal_dec(unsigned long)(Napi::Value obj, unsigned long *val)
{
  if(!obj.IsNumber()) {
    return SWIG_TypeError;
  }
  if (val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(obj.ToNumber(), num);
    if (num.Int64Value() < 0) {
      return SWIG_TypeError;
    }
    *val = static_cast<unsigned long>(num.Int64Value());
  }
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}

/* long long */

%fragment(SWIG_From_frag(long long), "header", fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN
Napi::Value SWIG_From_long_SS_long(Napi::Env env, long long val)
{
  return Napi::Number::New(env, val);
}
%#endif
}

%fragment(SWIG_AsVal_frag(long long),"header",
    fragment=SWIG_AsVal_frag(long),
    fragment="SWIG_CanCastAsInteger",
    fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN
int SWIG_AsVal_dec(long long)(Napi::Value obj, long long* val)
{
  if(!obj.IsNumber()) {
    return SWIG_TypeError;
  }

  if (val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(obj.ToNumber(), num);
    *val = static_cast<long long>(num.Int64Value());
  }
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
%#endif
}

/* unsigned long long */

%fragment(SWIG_From_frag(unsigned long long), "header", fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN
Napi::Value SWIG_From_unsigned_SS_long_SS_long(Napi::Env env, unsigned long long val)
{
  return Napi::Number::New(env, val);
}
%#endif
}


%fragment(SWIG_AsVal_frag(unsigned long long),"header",
    fragment=SWIG_AsVal_frag(unsigned long),
    fragment="SWIG_CanCastAsInteger",
    fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN
int SWIG_AsVal_dec(unsigned long long)(Napi::Value obj, unsigned long long *val)
{
  if(!obj.IsNumber()) {
    return SWIG_TypeError;
  }
  if (obj.ToNumber().Int64Value() < 0) {
    return SWIG_TypeError;
  }
  if (val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(obj.ToNumber(), num);
    *val = static_cast<unsigned long long>(num.Int64Value());
  }
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
%#endif
}


/* float */

%fragment(SWIG_From_frag(float), "header") {
SWIGINTERN
Napi::Value SWIG_From_float(Napi::Env env, float val)
{
  return Napi::Number::New(env, val);
}
}

%fragment(SWIG_AsVal_frag(float),"header") {
SWIGINTERN
int SWIG_AsVal_dec(float)(Napi::Value obj, float *val)
{
  if(!obj.IsNumber()) {
    return SWIG_TypeError;
  }

  if(val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(obj.ToNumber(), num);
    *val = static_cast<float>(num.DoubleValue());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}


/* double */

%fragment(SWIG_From_frag(double), "header") {
SWIGINTERN
Napi::Value SWIG_From_double(Napi::Env env, double val)
{
  return Napi::Number::New(env, val);
}
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN
int SWIG_AsVal_dec(double)(Napi::Value obj, double *val)
{
  if(!obj.IsNumber()) {
    return SWIG_TypeError;
  }

  if(val) {
    Napi::Number num;
    NAPI_CHECK_RESULT(obj.ToNumber(), num);
    *val = static_cast<double>(num.DoubleValue());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}
