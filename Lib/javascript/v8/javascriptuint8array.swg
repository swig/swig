
/* ------------------------------------------------------------
 *  utility methods for Uint8Array
 * ------------------------------------------------------------ */

#define SWIGV8_UINT8ARRAY v8::Local<v8::Uint8Array>

%fragment("SWIG_FromUint8Array", "header") {
SWIGINTERN int
SWIG_FromUint8Array(SWIGV8_VALUE valRef, void** cptr, size_t* psize, int *alloc)
{
  if (alloc == NULL || psize == NULL || cptr == NULL)
    return SWIG_TypeError;
  *alloc = 0;
  *cptr = NULL;
  *psize = 0;
  if (valRef->IsUint8Array()) {
    SWIGV8_UINT8ARRAY arr = SWIGV8_UINT8ARRAY::Cast(valRef);
    size_t len = (size_t)arr->Length();
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
        SWIGV8_VALUE val = SWIGV8_ARRAY_GET(arr, i);
        cbuf[i] = (unsigned char)SWIGV8_NUMBER_VALUE(val);
      }
    }
    return SWIG_OK;
  }
  return valRef->IsNull() || valRef->IsUndefined() ? SWIG_OK : SWIG_TypeError;
}
}

%fragment("SWIG_ToUint8Array", "header") {
SWIGINTERN SWIGV8_VALUE SWIG_ToUint8Array(void* buf, size_t len)
{
  if (buf != NULL && len > 0) {
    size_t i;
    unsigned char* cbuf = (unsigned char*)buf;
    v8::Local<v8::ArrayBuffer> ab = v8::ArrayBuffer::New(v8::Isolate::GetCurrent(), len);
    SWIGV8_UINT8ARRAY arr = v8::Uint8Array::New(ab, 0, len);
    for (i = 0; i < len; i++) {
      SWIGV8_VALUE val = SWIGV8_INTEGER_NEW_UNS(cbuf[i]);
      SWIGV8_ARRAY_SET(arr, i, val);
    }
    return arr;
  }
  return SWIGV8_UNDEFINED();
}
}
