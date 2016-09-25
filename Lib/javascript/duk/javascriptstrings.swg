/* ------------------------------------------------------------
 *  utility methods for char strings
 * ------------------------------------------------------------ */

%include "typemaps/swigmacros.swg";

%types(char *);

%fragment("SWIG_pchar_descriptor","header") {
SWIGINTERN swig_type_info*
SWIG_pchar_descriptor(void)
{
  static int init = 0;
  static swig_type_info* info = 0;
  if (!init) {
    info = SWIG_TypeQuery("_p_char");
    init = 1;
  }
  return info;
}
}

%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_duk_AsCharPtrAndSize(duk_context *ctx, duk_idx_t idx, char **cptr, size_t *psize, int *alloc)
{
  const char *js_str;
  duk_size_t js_str_len;
  char *cstr; // = (char*) %new_array(, char);
  
  if(duk_is_string(ctx, idx)) {
    /* duk_get_lstring returns the length including 0-terminator */
    cstr = (char*)duk_get_string(ctx, idx);
    js_str_len = duk_get_length(ctx, idx);

    if(alloc) *alloc = SWIG_NEWOBJ;
    /* Cast just to be explicit. */
    if(psize) *psize = (size_t)js_str_len;
    if(cptr) *cptr = cstr;

    return SWIG_OK;
  } else {
	  /* try if the object is a wrapped char[] */
	  swig_type_info *pchar_descriptor = SWIG_pchar_descriptor();

	  if (pchar_descriptor) {
	    
		void *vptr = NULL;
		if (SWIG_ConvertPtr(ctx, idx, &vptr, pchar_descriptor, 0) == SWIG_OK) {
		  if (cptr) *cptr = (char *) vptr;
		  if (psize) *psize = vptr ? strlen((char *)vptr) : 0;
		  if (alloc) *alloc = SWIG_OLDOBJ;
		  return SWIG_OK;
		}
	  }
	  return SWIG_TypeError;
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


%typemap(in,fragment="SWIG_AsCharPtrAndSize") (char *STRING, size_t SIZE) {
  {
	  if (SWIG_AsCharPtrAndSize($input, (char**)&$1, (size_t*)&$2, NULL) != SWIG_OK) {
			duk_push_string(ctx, "Expected binary string in $input");
			goto fail;
	  }
  }
}

%typemap(out, fragment="SWIG_FromCharPtrAndSize") (char *STRING, size_t SIZE) {
	SWIG_FromCharPtrAndSize((const char*)$1, $2);
}

%apply (char *STRING, size_t SIZE) { (      char *STRING, int SIZE)    ,
                                       (const char *STRING, int SIZE)    ,
                                       (const char *STRING, size_t SIZE) ,
                                       (      void *STRING, int SIZE)    ,
                                       (const void *STRING, int SIZE)    ,
                                       (const void *STRING, size_t SIZE) ,
                                       (      void *STRING, size_t SIZE) }

%insert(runtime) %{
#define SWIG_AsCharPtrAndSize(idx, cptr, psize, alloc)  SWIG_duk_AsCharPtrAndSize(ctx, idx, cptr, psize, alloc)
#define SWIG_FromCharPtrAndSize(cptr, size)  SWIG_duk_FromCharPtrAndSize(ctx, cptr, size)
#define SWIG_FromCharPtr(cptr) SWIG_duk_FromCharPtr(ctx, cptr)
%}
