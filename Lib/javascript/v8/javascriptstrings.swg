
/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */
%fragment("SWIG_AsCharPtrAndSize", "header", fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(SWIGV8_VALUE valRef, char** cptr, size_t* psize, int *alloc)
{
  if(valRef->IsString()) {
%#if (V8_MAJOR_VERSION-0) < 4 && (SWIG_V8_VERSION < 0x031903)
    v8::Handle<v8::String> js_str = SWIGV8_TO_STRING(valRef);
%#else
    v8::Local<v8::String> js_str = SWIGV8_TO_STRING(valRef);
%#endif

    size_t len = SWIGV8_UTF8_LENGTH(js_str) + 1;
    char* cstr = new char[len];
    SWIGV8_WRITE_UTF8(js_str, cstr, len);
    
    if(alloc) *alloc = SWIG_NEWOBJ;
    if(psize) *psize = len;
    if(cptr) *cptr = cstr;
    
    return SWIG_OK;
  } else {
    if(valRef->IsObject()) {
      SWIGV8_OBJECT obj = SWIGV8_TO_OBJECT(valRef);
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
SWIGINTERNINLINE SWIGV8_VALUE
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle extra long strings
      return SWIGV8_UNDEFINED();
    } else {
%#if (V8_MAJOR_VERSION-0) < 4 && (SWIG_V8_VERSION < 0x031903)
      v8::Handle<v8::String> js_str = SWIGV8_STRING_NEW2(carray, size);
%#else
      v8::Local<v8::String> js_str = SWIGV8_STRING_NEW2(carray, size);
%#endif
      return js_str;
    }
  } else {
    return SWIGV8_UNDEFINED();
  }
}
}
