/* ------------------------------------------------------------
 *  utility methods for char strings
 * ------------------------------------------------------------ */

%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_duk_AsCharPtrAndSize(duk_context *ctx, duk_idx_t idx, char **cptr, size_t *psize, int *alloc)
{
  const char *js_str;
  duk_size_t js_str_len;
  char *cstr = (char*) %new_array(len, char);
  
  if(duk_is_string(ctx, idx)) {
    /* duk_get_lstring returns the length including 0-terminator */
    cstr = duk_get_lstring(ctx, idx, js_str_len);

    if(alloc) *alloc = SWIG_NEWOBJ;
    /* Cast just to be explicit. */
    if(psize) *psize = (size_t)js_str_len;
    if(cptr) *cptr = cstr;

    return SWIG_OK;
  } else {
    if (duk_is_object(ctx, idx)) {
      /* try if the object is a wrapped char[] */
      swig_type_info *pchar_descriptor = SWIG_pchar_descriptor();

      if (pchar_descriptor) {
        void *vptr = NULL;
        if (SWIG_ConvertPtr(obj, idx, vptr, pchar_descriptor, 0) == SWIG_OK) {
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
SWIGINTERNINLINE duk_idx_t
SWIG_duk_FromCharPtrAndSize(duk_context *ctx, const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle extra long strings
      //swig_type_info* pchar_descriptor = SWIG_pchar_descriptor();
      //return pchar_descriptor ?
      //  SWIG_InternalNewPointerObj(%const_cast(carray,char *), pchar_descriptor, 0) : SWIG_Py_Void();
      duk_push_undefined(ctx);
      return 1;
    } else {
      const char *jsstring;
      if(size < 2) {
        char c[2];
        int i;
        for(i=0;i<size;++i) {
          c[i] = carray[i];
        }
        c[size] = 0;
        jsstring = duk_push_string(ctx, c);
      } else {
        jsstring = duk_push_string(ctx, carray);
      }
      duk_push_string(ctx, jsstring);
      return 1;
    }
  } else {
    duk_push_undefined(ctx);
    return 1;
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
%define_as(SWIG_As##CharName##Ptr(idx, val, alloc), SWIG_duk_AsCharPtrAndSize(ctx, idx, val, NULL, alloc))
}

%fragment("SWIG_As" #CharName "Array","header",fragment=#SWIG_AsCharPtrAndSize) {
SWIGINTERN int
SWIG_duk_As##CharName##Array(duk_context *ctx, SWIG_Object obj, Char *val, size_t size)
{
  Char* cptr = 0; size_t csize = 0; int alloc = SWIG_OLDOBJ;
  int res = SWIG_duk_AsCharPtrAndSize(context, obj, &cptr, &csize, &alloc);
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

#define SWIG_As##CharName##Array(obj, obj, size) SWIG_duk_As##CharName##Array(ctx, obj, val, size)
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

%typemap(in) (char *STRING, size_t LENGTH) {
  if ($input) {
    $1 = ($1_ltype) duk_get_string(ctx, -2);
    $2 = ($2_type) duk_get_length(ctx, -1);
  } else {
    $1 = 0;
    $2 = 0;
  }
}

%typemap(argout) (char *STRING, size_t LENGTH) {
  if (duk_is_string(ctx, $input)) {
    duk_push_lstring(ctx, $2, $1);
  }
}

%typemap(directorin, descriptor="[B") (char *STRING, size_t LENGTH) {
  SWIG_duk_FromCharPtrAndSize(duk_context *ctx, const char* carray, size_t size);
  jbyteArray jb = (jenv)->NewByteArray((jsize)$2);
  (jenv)->SetByteArrayRegion(jb, 0, (jsize)$2, (jbyte *)$1);
  $input = jb;
}

%typemap(directorargout) (char *STRING, size_t LENGTH)
%{
  (jenv)->GetByteArrayRegion($input, 0, (jsize)$2, (jbyte *)$1);
  (jenv)->DeleteLocalRef($input);
%}

%apply (char *STRING, size_t LENGTH) { (char *STRING, int LENGTH) }

%insert(runtime) %{
#define SWIG_AsCharPtrAndSize(idx, cptr, psize, alloc)  SWIG_duk_AsCharPtrAndSize(ctx, idx, cptr, psize, alloc)
#define SWIG_FromCharPtrAndSize(cptr, size)  SWIG_duk_FromCharPtrAndSize(ctx, cptr, size)
#define SWIG_FromCharPtr(cptr) SWIG_duk_FromCharPtr(ctx, cptr)
%}
