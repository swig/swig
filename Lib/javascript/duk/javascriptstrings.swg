/* ------------------------------------------------------------
 *  utility methods for char strings
 * ------------------------------------------------------------ */
%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERN duk_ret_t
SWIG_duk_AsCharPtrAndSize(duk_context *ctx, void *valRef, char **cptr, size_t* psize, int *alloc)
{
	duk_idx_t idx = duk_push_heapptr(valRef);
	if (duk_is_string(ctx, idx)) {
    char *cstr = (char*) %new_array(len, char);
    duk_push_string(cstr);
	} else if(duk_is_object(ctx, idx)) {
    // try if the object is a wrapped char[]
    swig_type_info *pchar_descriptor = SWIG_pchar_descriptor();
    if (pchar_descriptor) {
      void* vptr = 0;
      if (SWIG_ConvertPtr(obj, &vptr, pchar_descriptor, 0) == SWIG_OK) {
        if (cptr) *cptr = (char *) vptr;
        if (psize) *psize = vptr ? (strlen((char *)vptr) + 1) : 0;
        if (alloc) *alloc = SWIG_OLDOBJ;
        return SWIG_OK;
      }
    }		
	} else {
			return SWIG_TypeError;
	}
}
}

%fragment("SWIG_FromCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERNINLINE duk_ret_t
SWIG_duk_FromCharPtrAndSize(duk_context *ctx, const char *carray, size_t size)
{
	
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle these extra long strings
			// size_t is unsigned, so it can be larger than INT_MAX
      return 0;
    } else {
      duk_push_lstring(ctx, carray, size);
      return duk_get_top(ctx);
    }
  } else {
		return 0;
  }
}
}

%define %_typemap2_string(StringCode, CharCode,
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
SWIG_duk_From##CharName##Ptr(duk_context *ctx, const Char *cptr)
{
  return SWIG_duk_FromCharPtrAndSize(ctx, cptr, (cptr ? SWIG_CharPtrLen(cptr) : 0));
}
}

%fragment("SWIG_From"#CharName"Array","header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object
SWIG_duk_From##CharName##Array(duk_context *ctx, const Char *cptr, size_t size)
{
  return SWIG_duk_FromCharPtrAndSize(ctx, cptr, size);
}
}

%fragment("SWIG_As" #CharName "Ptr","header",fragment=#SWIG_AsCharPtrAndSize) {
%define_as(SWIG_As##CharName##Ptr(obj, val, alloc), SWIG_duk_AsCharPtrAndSize(ctx, obj, val, NULL, alloc))
}

%fragment("SWIG_As" #CharName "Array","header",fragment=#SWIG_AsCharPtrAndSize) {
SWIGINTERN int
SWIG_duk_As##CharName##Array(duk_context *ctx, SWIG_Object obj, Char *val, size_t size)
{
  Char* cptr = 0; size_t csize = 0; int alloc = SWIG_OLDOBJ;
  int res = SWIG_duk_AsCharPtrAndSize(ctx, obj, &cptr, &csize, &alloc);
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

#define SWIG_As##CharName##Array(obj, val, size) SWIG_duk_As##CharName##Array(ctx, obj, val, size)
}

/* Char */

%fragment(SWIG_From_frag(Char),"header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object
SWIG_From_dec(Char)(Char c)
{
  return SWIG_duk_FromCharPtrAndSize(ctx, &c,1);
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
#define SWIG_AsCharPtrAndSize(val, cptr, psize, alloc)  SWIG_duk_AsCharPtrAndSize(ctx, val, cptr, psize, alloc)
#define SWIG_FromCharPtrAndSize(cptr, size)  SWIG_duk_FromCharPtrAndSize(ctx, cptr, size)
#define SWIG_FromCharPtr(cptr) SWIG_duk_FromCharPtr(ctx, cptr)
%}
