/* ------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------ */

%{
SWIGINTERN int SWIG_AsVal_string SWIG_JSC_AS_DECL_ARGS(JSValueRef obj, JSStringRef* str)
{
  if (!JSValueIsString SWIG_JSC_FROM_CALL_ARGS(obj)) {
    return SWIG_TypeError;
  }
  if(str != SWIG_NULLPTR) {
    *str = JSValueToStringCopy SWIG_JSC_AS_CALL_ARGS(obj, SWIG_NULLPTR);
  }
  return SWIG_OK;
}
%}

%typemap(in) (int ARGC, char **ARGV) {
  int i, len;
  size_t arraysize;
  JSObjectRef array;
  if (!JSValueIsArray SWIG_JSC_FROM_CALL_ARGS($input)) {
    SWIG_exception_fail(SWIG_ERROR, "not array");
  }
  array = JSValueToObject SWIG_JSC_AS_CALL_ARGS($input, SWIG_NULLPTR);
  len = SWIGJSC_ArrayLength SWIG_JSC_FROM_CALL_ARGS(array);
  arraysize = (len+1)*sizeof($*2_ltype);
  $1 = len;
  $2 = ($2_ltype) malloc(arraysize);
  if ($2 == SWIG_NULLPTR) {
    SWIG_exception_fail(SWIG_ERROR, "memory allocation of array failed");
  }
  memset($2, 0, arraysize);
  for (i = 0; i < len; i++) {
    int res, slen;
    $*2_ltype pstr;
    JSStringRef str;
    JSValueRef jsvalue = JSObjectGetPropertyAtIndex(context, array, i, SWIG_NULLPTR);
    res = SWIG_AsVal_string SWIG_JSC_AS_CALL_ARGS(jsvalue, &str);
    if (!SWIG_IsOK(res)) {
      SWIG_exception_fail(SWIG_ERROR, "failed to convert to string");
    }
    slen = JSStringGetMaximumUTF8CStringSize(str);
    pstr = ($*2_ltype) malloc(slen);
    if (pstr == SWIG_NULLPTR) {
      SWIG_exception_fail(SWIG_ERROR, "memory allocation of a string failed");
    }
    if (slen) {
      res = JSStringGetUTF8CString(str, pstr, slen);
      if (res > slen) {
        SWIG_exception_fail(SWIG_ERROR, "wrong string length");
      }
    }
    $2[i] = pstr;
  }
  $2[i] = SWIG_NULLPTR;
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2 != SWIG_NULLPTR) {
    $1_ltype i;
    for (i = 0; i < $1; i++) {
      free((void *)$2[i]);
    }
    free((void *)$2);
  }
}
