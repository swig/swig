/* ------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------ */

%{
#ifndef SWIGV8_VALUE_TO_ARRAY
# define SWIGV8_VALUE_TO_ARRAY(val) SWIGV8_ARRAY::Cast(val)
#endif
#ifndef SWIGV8_STRING
# define SWIGV8_STRING v8::Local<v8::String>
#endif

SWIGINTERN int SWIG_AsVal_string (SWIGV8_VALUE valRef, SWIGV8_STRING *str)
{
  if (!valRef->IsString()) {
    return SWIG_TypeError;
  }
  if(str != SWIG_NULLPTR) {
      *str = SWIGV8_TO_STRING(valRef);
  }
  return SWIG_OK;
}
%}

%typemap(in) (int ARGC, char **ARGV) {
  $1_ltype i, len;
  size_t arraysize;
  SWIGV8_ARRAY array;
  if (!$input->IsArray()) {
    SWIG_exception_fail(SWIG_ERROR, "not array");
  }
  array = SWIGV8_VALUE_TO_ARRAY($input);
  len = array->Length();
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
    SWIGV8_STRING str;
    SWIGV8_VALUE jsvalue = SWIGV8_ARRAY_GET(array, i);
    res = SWIG_AsVal_string(jsvalue, &str);
    if (!SWIG_IsOK(res)) {
      SWIG_exception_fail(SWIG_ERROR, "failed to convert to string");
    }
    slen = SWIGV8_UTF8_LENGTH(str);
    pstr = ($*2_ltype) malloc(slen + 1);
    if (pstr == SWIG_NULLPTR) {
      SWIG_exception_fail(SWIG_ERROR, "memory allocation of a string failed");
    }
    if (slen) {
      res = SWIGV8_WRITE_UTF8(str, pstr, slen);
      if (res != slen) {
        SWIG_exception_fail(SWIG_ERROR, "wrong string length");
      }
    }
    pstr[slen] = 0;
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
