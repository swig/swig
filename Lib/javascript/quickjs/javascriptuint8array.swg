
/* ------------------------------------------------------------
 *  utility methods for Uint8Array
 * ------------------------------------------------------------ */

%fragment("SWIG_FromUint8Array", "header") {
#define SWIG_FromUint8Array(val, cptr, psize, alloc) SWIG_QuickJS_FromUint8Array(ctx, val, cptr, psize, alloc)
SWIGINTERN int
SWIG_QuickJS_FromUint8Array(JSContext *ctx, JSValueConst val, void** cptr, size_t* psize, int *alloc)
{
  JSValue abuf;
  uint8_t *b;
  size_t bsz;

  if (alloc == NULL || psize == NULL || cptr == NULL)
    return SWIG_TypeError;
  *alloc = 0;
  *cptr = NULL;
  *psize = 0;
  if (JS_IsObject(val)) {
    abuf = JS_GetTypedArrayBuffer(ctx, val, NULL, NULL, NULL);
    if (JS_IsException(abuf)) {
      return SWIG_TypeError;
    }
    b = JS_GetArrayBuffer(ctx, &bsz, abuf);
    if (b == NULL) {
      JS_FreeValue(ctx, abuf);
      return SWIG_TypeError;
    }
    if (bsz > 0) {
      size_t i;
      unsigned char *cbuf = %new_array(bsz, unsigned char);
      if (cbuf == NULL) {
        return SWIG_TypeError;
      }
      *alloc = SWIG_NEWOBJ;
      *cptr = (void*)cbuf;
      *psize = bsz;
      for (i = 0; i < bsz; i++) {
        cbuf[i] = (unsigned char)b[i];
      }
    }
    JS_FreeValue(ctx, abuf);
    return SWIG_OK;
  }
  return JS_IsNull(val) || JS_IsUndefined(val) ? SWIG_OK : SWIG_TypeError;
}
}

%fragment("SWIG_ToUint8Array", "header") {
#define SWIG_ToUint8Array(buf, len) SWIG_QuickJS_ToUint8Array(ctx, buf, len)
SWIGINTERN JSValue SWIG_QuickJS_ToUint8Array(JSContext *ctx, void* buf, size_t len)
{
  if (buf != NULL && len > 0) {

    size_t i;
    unsigned char* cbuf = (unsigned char*)buf;
    JSValue argv[1] = {JS_NewInt32(ctx, len)};
    JSValue arr = JS_NewTypedArray(ctx, 0, argv, JS_TYPED_ARRAY_UINT8);
    JSValue abuf;
    uint8_t *b;
    size_t bsz;
    if (JS_IsException(arr)) { return arr; }
    abuf = JS_GetTypedArrayBuffer(ctx, arr, NULL, NULL, NULL);
    if (JS_IsException(abuf)) {
      JS_FreeValue(ctx, arr);
      return abuf;
    }
    b = JS_GetArrayBuffer(ctx, &bsz, abuf);
    if (b == NULL) {
      JS_FreeValue(ctx, abuf);
      return JS_EXCEPTION;
    }
    for (i = 0; i < len; i++) {
      b[i] = cbuf[i];
    }
    JS_FreeValue(ctx, abuf);
    return arr;
  }
  return JS_UNDEFINED;
}
}
