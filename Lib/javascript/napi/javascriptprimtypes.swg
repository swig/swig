/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE
Napi::Value
SWIG_From_dec(bool)(Napi::Env env, bool value)
{
  return Napi::Boolean::New(env, value);
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
          fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN
int SWIG_AsVal_dec(bool)(Napi::Value obj, bool *val)
{
  if(!obj.IsBoolean()) {
    return SWIG_ERROR;
  }

  if (val) *val = obj.ToBoolean();
  return SWIG_OK;
}
}

/* int */

%fragment(SWIG_From_frag(int),"header") {
SWIGINTERNINLINE
Napi::Value SWIG_From_dec(int)(Napi::Env env, int value)
{
  return Napi::Number::New(env, value);
}
}

%fragment(SWIG_AsVal_frag(int),"header") {
SWIGINTERN
int SWIG_AsVal_dec(int)(Napi::Value valRef, int* val)
{
  if (!valRef.IsNumber()) {
    return SWIG_TypeError;
  }
  if (val) *val = valRef.ToNumber().Int32Value();

  return SWIG_OK;
}
}

/* long */

%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE
Napi::Value SWIG_From_dec(Napi::Env, long)(Napi::Env env, long value)
{
  return Napi::Number::New(env, value);
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
  if(val) *val = static_cast<long>(obj.ToNumber().Int64Value());

  return SWIG_OK;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
          fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE
Napi::Value SWIG_From_dec(Napi::Env, unsigned long)(Napi::Env env, unsigned long value)
{
  return Napi::Number::New(env, value);
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

  if(val) *val = static_cast<unsigned long>(obj.ToNumber().Uint32Value());

  return SWIG_OK;
}
}

/* long long */
// Note: these are copied from 'long' and probably need fixing

%fragment(SWIG_From_frag(long long),"header",
    fragment=SWIG_From_frag(long),
    fragment="SWIG_LongLongAvailable") {
%#ifdef SWIG_LONG_LONG_AVAILABLE
SWIGINTERNINLINE
Napi::Value SWIG_From_dec(Napi::Env, long long)(Napi::Env env, long long value)
{
  return Napi::Number::New(env, value);
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

  if(val) *val = static_cast<long long>(obj.ToNumber().Int64Value());

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
SWIGINTERNINLINE
Napi::Value SWIG_From_dec(Napi::Env, unsigned long long)(Napi::Env env, unsigned long long value)
{
  return Napi::Number::New(env, value);
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

  if(val) *val = static_cast<unsigned long long>(obj.ToNumber().Int64Value());

  return SWIG_OK;
}
%#endif
}

/* double */

%fragment(SWIG_From_frag(double),"header") {
SWIGINTERN
Napi::Value SWIG_From_dec(Napi::Env, double) (Napi::Env env, double val)
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

  if(val) *val = static_cast<double>(obj.ToNumber().DoubleValue());

  return SWIG_OK;
}
}
