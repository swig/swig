
/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */
%fragment("SWIG_AsCharPtrAndSize", "header", fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(Napi::Value valRef, char** cptr, size_t* psize, int *alloc)
{
  if(valRef.IsString()) {
    Napi::String js_str;
    NAPI_CHECK_RESULT(valRef.ToString(), js_str);

    std::string str = js_str.Utf8Value();
    size_t len = str.size() + 1;
    char* cstr = (char*) %new_array(len, char);
    memcpy(cstr, str.data(), len);
    
    if(alloc) *alloc = SWIG_NEWOBJ;
    if(psize) *psize = len;
    if(cptr) *cptr = cstr;
    
    return SWIG_OK;
  } else if (valRef.IsNull()) {
    if (cptr) *cptr = 0;
    return SWIG_OK;
  } else {
    if(valRef.IsObject()) {
      swig_type_info* pchar_descriptor = SWIG_pchar_descriptor();
      Napi::Object obj;
      NAPI_CHECK_RESULT(valRef.ToObject(), obj);
      // try if the object is a wrapped char[]
      if (pchar_descriptor) {
        void* vptr = 0;
        if (SWIG_ConvertPtr(obj, &vptr, pchar_descriptor, 0) == SWIG_OK) {
          if (cptr) *cptr = (char *) vptr;
          if (psize) *psize = vptr ? (strlen((char *)vptr) + 1) : 0;
          if (alloc) *alloc = SWIG_OLDOBJ;
          return SWIG_OK;
        }
      }
    }
  }
  goto fail;
fail:
  return SWIG_TypeError;
}
}


%fragment(SWIG_From_frag(char), "header") {
SWIGINTERNINLINE Napi::Value
SWIG_From_char(Napi::Env env, char c)
{
  Napi::String js_str = Napi::String::New(env, &c, 1);
  return js_str;
}
}


%fragment("SWIG_FromCharPtr", "header", fragment = "SWIG_FromCharPtrAndSize") {
// Override the default one with an empty one
}

%fragment("SWIG_FromCharPtrAndSize", "header") {
SWIGINTERNINLINE Napi::Value
SWIG_Env_FromCharPtrAndSize(Napi::Env env, const char* carray, size_t size)
{
  if (carray) {
    Napi::String js_str = Napi::String::New(env, carray, size);
    return js_str;
  } else {
    return env.Undefined();
  }
}
}

%insert(runtime) %{
#define SWIG_FromCharPtrAndSize(cptr, size) SWIG_Env_FromCharPtrAndSize(env, cptr, size)
#define SWIG_FromCharPtr(cptr)              SWIG_Env_FromCharPtrAndSize(env, cptr, strlen(cptr))
%}
