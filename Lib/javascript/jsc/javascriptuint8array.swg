
/* ------------------------------------------------------------
 *  utility methods for Uint8Array
 * ------------------------------------------------------------ */

%fragment("SWIG_FromUint8Array", "header") {
#define SWIG_FromUint8Array(valRef, cptr, psize, alloc) SWIG_ContextFromUint8Array(context, valRef, cptr, psize, alloc)
SWIGINTERN int
SWIG_ContextFromUint8Array(JSContextRef context, JSValueRef valRef, void** cptr, size_t* psize, int *alloc)
{
  if (alloc == NULL || psize == NULL || cptr == NULL)
    return SWIG_TypeError;
  *alloc = 0;
  *cptr = NULL;
  *psize = 0;
  if (JSValueGetTypedArrayType(context, valRef, NULL) == kJSTypedArrayTypeUint8Array) {
    JSObjectRef arr = JSValueToObject(context, valRef, NULL);
    size_t len = (size_t)SWIGJSC_ArrayLength(context, arr);
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
        JSValueRef val = JSObjectGetPropertyAtIndex(context, arr, i, NULL);
        cbuf[i] = (unsigned char)JSValueToNumber(context, val, NULL);
      }
    }
    return SWIG_OK;
  }
  return JSValueIsNull(context, valRef) || JSValueIsUndefined(context, valRef) ? SWIG_OK : SWIG_TypeError;
}
}

%fragment("SWIG_ToUint8Array", "header") {
#define SWIG_ToUint8Array(buf, len) SWIG_ContextToUint8Array(context, buf, len)
SWIGINTERN JSValueRef SWIG_ContextToUint8Array(JSContextRef context, void* buf, size_t len)
{
  if (buf != NULL && len > 0) {
    size_t i;
    unsigned char* cbuf = (unsigned char*)buf;
    JSObjectRef arr = JSObjectMakeTypedArray(context, kJSTypedArrayTypeUint8Array, len, NULL);
    for (i = 0; i < len; i++) {
      JSValueRef val = JSValueMakeNumber(context, cbuf[i]);
      JSObjectSetPropertyAtIndex(context, arr, i, val, NULL);
    }
    return arr;
  }
  return JSValueMakeUndefined(context);
}
}
