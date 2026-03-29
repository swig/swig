
/* ------------------------------------------------------------
 *  utility methods for Uint8Array
 * ------------------------------------------------------------ */

%fragment("SWIG_FromUint8Array", "header") {
SWIGINTERN int
SWIG_FromUint8Array(Napi::Value valRef, void** cptr, size_t* psize, int *alloc)
{
  if (alloc == NULL || psize == NULL || cptr == NULL)
    return SWIG_TypeError;
  *alloc = 0;
  *cptr = NULL;
  *psize = 0;
  if (valRef.IsTypedArray()) {
    Napi::Number num;
    size_t len = 0;
    Napi::TypedArray arr = valRef.As<Napi::TypedArray>();
    if (arr.TypedArrayType() != napi_uint8_array) {
      return SWIG_TypeError;
    }
    len = arr.ElementLength();
    if (len > 0) {
      size_t i;
      unsigned char *cbuf = %new_array(len, unsigned char);
      if (cbuf == NULL) {
        return SWIG_TypeError;
      }
      *alloc = SWIG_NEWOBJ;
      *cptr = (void*)cbuf;
      *psize = len;
      for (i = 0; i < len; i++) {
        NAPI_CHECK_RESULT(arr.Get(i).ToNumber(), num);
        cbuf[i] = (unsigned char)num.Uint32Value();
      }
    }
    return SWIG_OK;
  }
  return valRef.IsNull() || valRef.IsUndefined() ? SWIG_OK : SWIG_TypeError;
}
}

%fragment("SWIG_ToUint8Array", "header") {
#define SWIG_ToUint8Array(buf, len) SWIG_EnvToUint8Array(env, buf, len)
SWIGINTERN Napi::Value SWIG_EnvToUint8Array(Napi::Env env, void* buf, size_t len)
{
  if (buf != NULL && len > 0) {
    size_t i;
    unsigned char* cbuf = (unsigned char*)buf;
    Napi::Uint8Array arr = Napi::Uint8Array::New(env, len);
    for (i = 0; i < len; i++) {
      arr.Set(i, cbuf[i]);
    }
    return arr;
  }
  return env.Undefined();
}
}
