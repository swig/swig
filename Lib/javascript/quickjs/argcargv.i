/* ------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------ */

%{
SWIGINTERN int SWIG_AsVal_string(JSContext *ctx, JSValue obj, const char** str)
{
  if (!JS_IsString(obj)) {
    return SWIG_TypeError;
  }
  if (str) {
    *str = JS_ToCString(ctx, obj);
  }
  return SWIG_OK;
}
%}

%typemap(in) (int ARGC, char **ARGV) {
  int i, len;
  size_t arraysize;
  JSValue array;

  if (!JS_IsArray(ctx, $input)) {
    SWIG_exception_fail(SWIG_ERROR, "not array");
  }
  array = $input;

  len = SWIG_QuickJS_ArrayLength(ctx, array);
  arraysize = (len+1)*sizeof($*2_ltype);
  $1 = len;
  $2 = ($2_ltype) js_malloc(ctx, arraysize);
  if ($2 == NULL) {
    SWIG_exception_fail(SWIG_ERROR, "memory allocation of array failed");
  }
  memset($2, 0, arraysize);
  for (i = 0; i < len; i++) {
    int res;
    const char *str;
    JSValue jsvalue = JS_GetPropertyUint32(ctx, array, (uint32_t)i);
    res = SWIG_AsVal_string(ctx, jsvalue, &str);
    if (!SWIG_IsOK(res)) {
      SWIG_exception_fail(SWIG_ERROR, "failed to convert to string");
    }
    $2[i] = (char*)str;
    JS_FreeValue(ctx, jsvalue);
  }
  $2[i] = NULL;
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2) {
    $1_ltype i;
    for (i = 0; i < $1; i++) {
      JS_FreeCString(ctx, (const char*)$2[i]);
    }
    js_free(ctx, (void *)$2);
  }
}
