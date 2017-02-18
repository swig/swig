/* -----------------------------------------------------------------------------
 * rubywstrings.swg
 *
 * Currently, Ruby does not support Unicode or WChar properly, so these
 * are still treated as char arrays for now.
 * There are other libraries available that add support to this in
 * ruby including WString, FXString, etc.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor",fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(VALUE obj, wchar_t **cptr, size_t *psize, int *alloc)
{
  VALUE tmp;
  *alloc = SWIG_NEWOBJ;
  if(sizeof(wchar_t) == 4) {
    tmp = rb_str_conv_enc(obj, rb_enc_get(obj), rb_to_encoding(rb_str_new_cstr("UTF-32")) );
  } else if (sizeof(wchar_t) == 2) {
    tmp = rb_str_conv_enc(obj, rb_enc_get(obj), rb_to_encoding(rb_str_new_cstr("UTF-16")) );
  } else {
    rb_raise(rb_eRuntimeError, "unsupported wchar_t size");
  }
  return SWIG_AsCharPtrAndSize( tmp, (char**)cptr, psize, alloc);

}
}

%fragment("SWIG_FromWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor",fragment="SWIG_FromCharPtrAndSize") {
SWIGINTERNINLINE VALUE 
SWIG_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  VALUE ret = SWIG_FromCharPtrAndSize( (const char*)carray, size);
  rb_encoding* enc = rb_default_internal_encoding();
  if(sizeof(wchar_t) == 4) {
    rb_enc_associate(ret, rb_to_encoding(rb_str_new_cstr("UTF-32")));
  } else if (sizeof(wchar_t) == 2) {
    rb_enc_associate(ret, rb_to_encoding(rb_str_new_cstr("UTF-16")));
  } else {
    rb_raise(rb_eRuntimeError, "unsupported wchar_t size");
  }

  if( !enc ) {
    enc = rb_to_encoding(rb_str_new_cstr("UTF-8"));
  }
  return rb_str_conv_enc(ret, rb_enc_get(ret), enc );
}
}


