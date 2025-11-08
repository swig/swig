/* ------------------------------------------------------------
 *  utility methods for char strings
 * ------------------------------------------------------------ */
%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_QuickJS_AsCharPtrAndSize(JSContext *ctx, JSValueConst val, char** cptr, size_t* psize, int *alloc)
{
  if(JS_IsString(val)) {
    size_t len;
    const char *str;
    str = JS_ToCStringLen2(ctx, &len, val, 0);
    len+=1;
    char* cstr = (char*) %new_array(len, char);
    memcpy(cstr, str, len);
    JS_FreeCString(ctx, str);
    
    if(alloc) *alloc = SWIG_NEWOBJ;
    if(psize) *psize = len;
    if(cptr) *cptr = cstr;

    return SWIG_OK;
  
  } else if (JS_IsNull(val)) {
    if (cptr) *cptr = 0;
    return SWIG_OK;
  
  } else {
    if(JS_IsObject(val)) {
      // try if the object is a wrapped char[]
      swig_type_info* pchar_descriptor = SWIG_pchar_descriptor();
      if (pchar_descriptor) {
        void* vptr = 0;
        if (SWIG_IsOK(SWIG_ConvertPtr(val, &vptr, pchar_descriptor, 0))) {
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
SWIG_QuickJS_FromCharPtrAndSize(JSContext *ctx, const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle extra long strings?
      return JS_UNDEFINED;
    
    } else {
      JSValue result;
      if(size < 2) {
        char c[2];
        size_t i;
        for(i=0;i<size;++i) {
          c[i] = carray[i];
        }
        c[size] = 0;
        result = JS_NewStringLen(ctx, c, size);
      } else {
        result = JS_NewStringLen(ctx, carray, size);
      }
      return result;
    }
  } else {
    return JS_UNDEFINED;
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
SWIG_QuickJS_From##CharName##Ptr(JSContext *ctx, const Char *cptr)
{
  return SWIG_QuickJS_FromCharPtrAndSize(ctx, cptr, (cptr ? SWIG_CharPtrLen(cptr) : 0));
}
}

%fragment("SWIG_From"#CharName"Array","header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object
SWIG_QuickJS_From##CharName##Array(JSContext *ctx, const Char *cptr, size_t size)
{
  return SWIG_QuickJS_FromCharPtrAndSize(ctx, cptr, size);
}
}

%fragment("SWIG_As" #CharName "Ptr","header",fragment=#SWIG_AsCharPtrAndSize) {
%define_as(SWIG_As##CharName##Ptr(obj, val, alloc), SWIG_QuickJS_AsCharPtrAndSize(ctx, obj, val, NULL, alloc))
}

%fragment("SWIG_As" #CharName "Array","header",fragment=#SWIG_AsCharPtrAndSize) {
SWIGINTERN int
SWIG_QuickJS_As##CharName##Array(JSContext *ctx, SWIG_Object obj, Char *val, size_t size)
{
  Char* cptr = 0; size_t csize = 0; int alloc = SWIG_OLDOBJ;
  int res = SWIG_QuickJS_AsCharPtrAndSize(ctx, obj, &cptr, &csize, &alloc);
  if (SWIG_IsOK(res)) {
    if ((csize == size + 1) && cptr && !(cptr[csize-1])) --csize;
    if (csize <= size) {
      if (val) {
        if (csize) memcpy(val, cptr, csize*sizeof(Char));
        if (csize < size) memset(val + csize, 0, (size - csize)*sizeof(Char));
      }
      if (alloc == SWIG_NEWOBJ) {
        SWIG_DeleteCharArray(cptr);
        res = SWIG_DelNewMask(res);
      }
      return res;
    }
    if (alloc == SWIG_NEWOBJ) SWIG_DeleteCharArray(cptr);
  }
  return SWIG_TypeError;
}

#define SWIG_As##CharName##Array(obj, val, size) SWIG_QuickJS_As##CharName##Array(ctx, obj, val, size)
}

/* Char */

%fragment(SWIG_From_frag(Char),"header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object
SWIG_From_dec(Char)(Char c)
{
  return SWIG_QuickJS_FromCharPtrAndSize(ctx, &c,1);
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
  if (!SWIG_IsOK(res)) {
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
/* from javascriptstrings.swg */
#define SWIG_AsCharPtrAndSize(val, cptr, psize, alloc)  SWIG_QuickJS_AsCharPtrAndSize(ctx, val, cptr, psize, alloc)
#define SWIG_FromCharPtrAndSize(cptr, size)  SWIG_QuickJS_FromCharPtrAndSize(ctx, cptr, size)
#define SWIG_FromCharPtr(cptr) SWIG_QuickJS_FromCharPtr(ctx, cptr)
%}
