/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header", fragment="SWIG_Env_FromBool") {
#define SWIG_From_bool(d) SWIG_Env_FromBool(env, d)
}
%fragment("SWIG_Env_FromBool", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromBool(Napi::Env env, bool val)
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
fail:
  return SWIG_ERROR;
}
}

/* int */

%fragment(SWIG_From_frag(int),"header", fragment="SWIG_Env_FromInt") {
#define SWIG_From_int(d) SWIG_Env_FromInt(env, d)
}
%fragment("SWIG_Env_FromInt", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromInt(Napi::Env env, int val)
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

%fragment(SWIG_From_frag(unsigned int),"header", fragment="SWIG_Env_FromUInt") {
#define SWIG_From_unsigned_SS_int(d) SWIG_Env_FromUInt(env, d)
}
%fragment("SWIG_Env_FromUInt", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromUInt(Napi::Env env, unsigned int val)
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
    *val = static_cast<unsigned int>(num.Uint32Value());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}


/* short */

%fragment(SWIG_From_frag(short),"header", fragment="SWIG_Env_FromShort") {
#define SWIG_From_short(d) SWIG_Env_FromShort(env, d)
}
%fragment("SWIG_Env_FromShort", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromShort(Napi::Env env, short val)
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

%fragment(SWIG_From_frag(unsigned short),"header", fragment="SWIG_Env_FromUShort") {
#define SWIG_From_unsigned_SS_short(d) SWIG_Env_FromUShort(env, d)
}
%fragment("SWIG_Env_FromUShort", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromUShort(Napi::Env env, unsigned short val)
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
    *val = static_cast<unsigned short>(num.Uint32Value());
  }

  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}


/* long */

%fragment(SWIG_From_frag(long),"header", fragment="SWIG_Env_FromLong") {
#define SWIG_From_long(d) SWIG_Env_FromLong(env, d)
}
%fragment("SWIG_Env_FromLong", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromLong(Napi::Env env, long val)
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

%fragment(SWIG_From_frag(unsigned long),"header", fragment="SWIG_Env_FromULong") {
#define SWIG_From_unsigned_SS_long(d) SWIG_Env_FromULong(env, d)
}
%fragment("SWIG_Env_FromULong", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromULong(Napi::Env env, unsigned long val)
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
    *val = static_cast<unsigned long>(num.Uint32Value());
  }
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}
}

/* long long */
// Note: these are copied from 'long' and probably need fixing

%fragment(SWIG_From_frag(long long),"header", fragment="SWIG_Env_FromLLong") {
#define SWIG_From_long_long(d) SWIG_Env_FromLLong(env, d)
}
%fragment("SWIG_Env_FromLLong", "header") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN
Napi::Value SWIG_Env_FromLLong(Napi::Env env, long long val)
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
// Note: these are copied from 'unsigned long' and probably need fixing

%fragment(SWIG_From_frag(unsigned long long),"header", fragment="SWIG_Env_FromULLong") {
#define SWIG_From_unsigned_long_long(d) SWIG_Env_FromULLong(env, d)
}
%fragment("SWIG_Env_FromULLong", "header") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERN
Napi::Value SWIG_Env_FromULLong(Napi::Env env, unsigned long long val)
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

%fragment(SWIG_From_frag(float),"header", fragment="SWIG_Env_FromFloat") {
#define SWIG_From_float(d) SWIG_Env_FromFloat(env, d)
}
%fragment("SWIG_Env_FromFloat", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromFloat(Napi::Env env, float val)
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

%fragment(SWIG_From_frag(double),"header", fragment="SWIG_Env_FromDouble") {
#define SWIG_From_double(d) SWIG_Env_FromDouble(env, d)
}
%fragment("SWIG_Env_FromDouble", "header") {
SWIGINTERN
Napi::Value SWIG_Env_FromDouble(Napi::Env env, double val)
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
