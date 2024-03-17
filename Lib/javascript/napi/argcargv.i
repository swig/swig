/* ------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------ */

%{
SWIGINTERN int SWIG_AsVal_string (Napi::Value valRef, Napi::String *str)
{
  if (!valRef.IsString()) {
    return SWIG_TypeError;
  }
  if(str != SWIG_NULLPTR) {
      *str = valRef.ToString();
  }
  return SWIG_OK;
}
%}

%typemap(in) (int ARGC, char **ARGV) {
  $1_ltype i, len;
  size_t arraysize;
  Napi::Array array;
  if (!$input.IsArray()) {
    SWIG_exception_fail(SWIG_ERROR, "not array");
  }
  array = $input.As<Napi::Array>();
  len = array.Length();
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
    Napi::String napi_str;
    Napi::Value jsvalue = array.Get(i);
    res = SWIG_AsVal_string(jsvalue, &napi_str);
    if (!SWIG_IsOK(res)) {
      SWIG_exception_fail(SWIG_ERROR, "failed to convert to string");
    }
    std::string str = napi_str.Utf8Value();
    slen = str.size();
    pstr = ($*2_ltype) malloc(slen + 1);
    if (pstr == SWIG_NULLPTR) {
      SWIG_exception_fail(SWIG_ERROR, "memory allocation of a string failed");
    }
    if (slen) {
      memcpy(pstr, str.c_str(), slen);
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
