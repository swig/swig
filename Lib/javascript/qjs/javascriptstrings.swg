/* ------------------------------------------------------------
 *  utility methods for char strings
 * ------------------------------------------------------------ */
%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_QJS_AsCharPtrAndSize(JSContext* context, JSValue valRef, char** cptr, size_t* psize, int *alloc)
{
  if(JS_IsString(valRef)) {
    JSString js_str = JS_ToString(context, JS_DupValue(context, valRef));
    size_t len;
    // char* cstr = (char*) %new_array(len, char);
    char *cstr = JS_ToCStringLen(context, &len, js_str);
    /* JSStringGetUTF8CString returns the length including 0-terminator */
    // len = JSStringGetUTF8CString(js_str, cstr, len);

    if(alloc) *alloc = SWIG_NEWOBJ;
    if(psize) *psize = len;
    if(cptr) *cptr = cstr;

    return SWIG_OK;
  } else {
    if(JS_IsObject(valRef)) {
      JSObject* obj = JS_ToObjectcontext, valRef);
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
SWIGINTERNINLINE JSValue
SWIG_QJS_FromCharPtrAndSize(JSContext* context, const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle extra long strings
      return JS_UNDEFINED;
    } else {
      JSString js_str = JS_NewStringLen(context, carray, size);
      return js_str;
    }
  } else {
    return JS_UNDEFINED;
  }
}
}
