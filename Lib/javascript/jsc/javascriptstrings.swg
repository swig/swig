/* ------------------------------------------------------------
 *  utility methods for char strings
 * ------------------------------------------------------------ */
%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_JSC_AsCharPtrAndSize(JSContextRef context, JSValueRef valRef, char** cptr, size_t* psize, int *alloc)
{
  if(JSValueIsString(context, valRef)) {
    JSStringRef js_str = JSValueToStringCopy(context, valRef, NULL);
    size_t len = JSStringGetMaximumUTF8CStringSize(js_str);
    char* cstr = (char*) %new_array(len, char);
    /* JSStringGetUTF8CString returns the length including 0-terminator */
    len = JSStringGetUTF8CString(js_str, cstr, len);

    if(alloc) *alloc = SWIG_NEWOBJ;
    if(psize) *psize = len;
    if(cptr) *cptr = cstr;

    return SWIG_OK;
  } else if (JSValueIsNull(context, valRef)) {
    if (cptr) *cptr = 0;
    return SWIG_OK;
  } else {
    if(JSValueIsObject(context, valRef)) {
      JSObjectRef obj = JSValueToObject(context, valRef, NULL);
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

%fragment("SWIG_FromCharPtrAndSize","header",fragment="SWIG_pchar_descriptor",fragment="<string.h>") {
SWIGINTERNINLINE JSValueRef
SWIG_JSC_FromCharPtrAndSize(JSContextRef context, const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle extra long strings
      //swig_type_info* pchar_descriptor = SWIG_pchar_descriptor();
      //return pchar_descriptor ?
      //  SWIG_InternalNewPointerObj(%const_cast(carray,char *), pchar_descriptor, 0) : SWIG_Py_Void();
      return JSValueMakeUndefined(context);
    } else {
      JSStringRef jsstring;
      JSValueRef result;
      /* The size chars need not be NUL terminated, such as a full char array, so terminate a copy for JSC */
      char *cstr = (char *)%new_array(size + 1, char);
      if (size)
        memcpy(cstr, carray, size);
      cstr[size] = 0;
      jsstring = JSStringCreateWithUTF8CString(cstr);
      %delete_array(cstr);
      result = JSValueMakeString(context, jsstring);
      JSStringRelease(jsstring);
      return result;
    }
  } else {
    return JSValueMakeUndefined(context);
  }
}
}

%define %_typemap2_string(StringCode, CharCode,
			 WarningLeakMsg,
			 Char, CharName,
			 SWIG_AsCharPtrAndSize,
			 SWIG_FromCharPtrAndSize,
			 SWIG_CharPtrLen,
       SWIG_CharBufLen,
			 SWIG_NewCopyCharArray,
			 SWIG_DeleteCharArray,
			 FragLimits, CHAR_MIN, CHAR_MAX)

%fragment("SWIG_From"#CharName"Ptr","header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object
SWIG_JSC_From##CharName##Ptr(JSContextRef context, const Char *cptr)
{
  return SWIG_JSC_FromCharPtrAndSize(context, cptr, (cptr ? SWIG_CharPtrLen(cptr) : 0));
}
}

%fragment("SWIG_From"#CharName"Array","header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object
SWIG_JSC_From##CharName##Array(JSContextRef context, const Char *cptr, size_t size)
{
  return SWIG_JSC_FromCharPtrAndSize(context, cptr, size);
}
}

%fragment("SWIG_As" #CharName "Ptr","header",fragment=#SWIG_AsCharPtrAndSize) {
%define_as(SWIG_As##CharName##Ptr(obj, val, alloc), SWIG_JSC_AsCharPtrAndSize(context, obj, val, NULL, alloc))
}

%fragment("SWIG_As" #CharName "Array","header",fragment=#SWIG_AsCharPtrAndSize,fragment="SWIG_Copy" #CharName "Array") {
SWIGINTERN int
SWIG_JSC_As##CharName##Array(JSContextRef context, SWIG_Object obj, Char *val, size_t size)
{
  Char* cptr = 0; size_t csize = 0; int alloc = SWIG_OLDOBJ;
  int res = SWIG_JSC_AsCharPtrAndSize(context, obj, &cptr, &csize, &alloc);
  if (SWIG_IsOK(res)) {
    int copied;
    if (!cptr)
      return SWIG_NullReferenceError;
    /* csize includes the NUL terminator */
    copied = SWIG_Copy##CharName##Array(val, size, cptr, csize - 1);
    if (alloc == SWIG_NEWOBJ) {
      SWIG_DeleteCharArray(cptr);
      res = SWIG_DelNewMask(res);
    }
    if (copied)
      return res;
  }
  return SWIG_TypeError;
}

#define SWIG_As##CharName##Array(obj, val, size) SWIG_JSC_As##CharName##Array(context, obj, val, size)
}

/* Char */

%fragment(SWIG_From_frag(Char),"header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object
SWIG_From_dec(Char)(Char c)
{
  return SWIG_JSC_FromCharPtrAndSize(context, &c,1);
}
}

%fragment(SWIG_AsVal_frag(Char),"header",
          fragment="SWIG_As"#CharName"Array",
          fragment=FragLimits,
          fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
SWIG_AsVal_dec(Char)(SWIG_Object obj, Char *val)
{
  int res = SWIG_As##CharName##Array(obj, val, 1);
  /* NULL is not a char, nor is it converted as a number, which gives 0 in Perl for undef. A type error lets an overload
   * dispatcher that tries each overload in turn, as in Javascript, try the next one. */
  if (res == SWIG_NullReferenceError) {
    res = SWIG_TypeError;
  } else if (!SWIG_IsOK(res)) {
    long v;
    res = SWIG_AddCast(SWIG_AsVal(long)(obj, &v));
    if (SWIG_IsOK(res)) {
      if ((CHAR_MIN <= v) && (v <= CHAR_MAX)) {
        if (val) *val = %numeric_cast(v, Char);
      } else {
        res = SWIG_OverflowError;
      }
    }
  }
  return res;
}
}

%_typemap_string(StringCode,
                 Char,
                 WarningLeakMsg,
                 SWIG_AsCharPtrAndSize,
                 SWIG_FromCharPtrAndSize,
                 SWIG_CharPtrLen,
                 SWIG_CharBufLen,
                 SWIG_As##CharName##Ptr,
                 SWIG_From##CharName##Ptr,
                 SWIG_As##CharName##Array,
                 SWIG_NewCopyCharArray,
                 SWIG_DeleteCharArray)

%enddef

%insert(runtime) %{
#define SWIG_AsCharPtrAndSize(val, cptr, psize, alloc)  SWIG_JSC_AsCharPtrAndSize(context, val, cptr, psize, alloc)
#define SWIG_FromCharPtrAndSize(cptr, size)  SWIG_JSC_FromCharPtrAndSize(context, cptr, size)
#define SWIG_FromCharPtr(cptr) SWIG_JSC_FromCharPtr(context, cptr)
%}
