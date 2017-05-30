/* -----------------------------------------------------------------------------
 * rubywstrings.swg
 *
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor",fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(VALUE obj, wchar_t **cptr, size_t *psize, int *alloc)
{
  VALUE tmp = rb_str_conv_enc(obj, rb_enc_get(obj),
                                   rb_to_encoding(rb_str_new_cstr( SWIG_RUBY_WSTRING_ENCODING )) );
  *alloc = SWIG_NEWOBJ;

  return SWIG_AsCharPtrAndSize(tmp, (char**)cptr, psize, alloc);
}
}

%fragment("SWIG_FromWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor",fragment="SWIG_FromCharPtrAndSize") {
SWIGINTERNINLINE VALUE 
SWIG_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  VALUE ret = SWIG_FromCharPtrAndSize( (const char*)carray, size);
  rb_encoding* enc = rb_default_internal_encoding();

  rb_enc_associate(ret, rb_to_encoding(rb_str_new_cstr( SWIG_RUBY_WSTRING_ENCODING )) );

  if( !enc ) {
    enc = rb_to_encoding(rb_str_new_cstr( SWIG_RUBY_INTERNAL_ENCODING ));
  }
  return rb_str_conv_enc(ret, rb_enc_get(ret), enc);
}
}


