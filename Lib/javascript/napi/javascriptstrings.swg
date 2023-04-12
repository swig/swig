
/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */
%fragment("SWIG_AsCharPtrAndSize", "header", fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(Napi::Value valRef, char** cptr, size_t* psize, int *alloc)
{
  if(valRef.IsString()) {
    Napi::String js_str = valRef.ToString();

    std::string s = js_str.Utf8Value();
    size_t len = s.size() + 1;
    char* cstr = (char*) %new_array(len, char);
    memcpy(cstr, str.data(), len);
    
    if(alloc) *alloc = SWIG_NEWOBJ;
    if(psize) *psize = len;
    if(cptr) *cptr = cstr;
    
    return SWIG_OK;
  } else {
    if(valRef.IsObject()) {
      Napi::Object obj = valRef.ToObject();
      // try if the object is a wrapped char[]
      swig_type_info* pchar_descriptor = SWIG_pchar_descriptor();
      if (pchar_descriptor) {
        void* vptr = 0;
        if (SWIG_ConvertPtr(obj, &vptr, pchar_descriptor, 0) == SWIG_OK) {
          if (cptr) *cptr = (char *) vptr;
          if (psize) *psize = vptr ? (strlen((char *)vptr) + 1) : 0;
          if (alloc) *alloc = SWIG_OLDOBJ;
          return SWIG_OK;
        }
      }
      return SWIG_TypeError;
    } else {
      return SWIG_TypeError;
    }
  }
}
}

%fragment("SWIG_FromCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERNINLINE Napi::Value
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle extra long strings
      return SWIGV8_UNDEFINED();
    } else {
      v8::Local<v8::String> js_str = SWIGV8_STRING_NEW2(carray, size);
      return js_str;
    }
  } else {
    return SWIGV8_UNDEFINED();
  }
}
}
