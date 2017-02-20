/* -----------------------------------------------------------------------------
 * rubywstrings.swg
 *
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor",fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(VALUE obj, wchar_t **cptr, size_t *psize, int *alloc)
{

  if (TYPE(obj) == T_STRING) {
    VALUE tmp = rb_str_conv_enc(obj, rb_enc_get(obj),
                                rb_to_encoding(rb_str_new_cstr( SWIG_RUBY_WSTRING_ENCODING )) );
    wchar_t* cstr = (wchar_t*) StringValuePtr(tmp);
    size_t   size = RSTRING_LEN(tmp) / sizeof(wchar_t) + 1;

    if( RSTRING_LEN(tmp) % sizeof(wchar_t) != 0 ) {
        rb_raise(rb_eRuntimeError,
                 "The length of the byte sequence of converted string is not a multiplier of sizeof(wchar_t). Invalid byte sequence is given. Or invalid SWIG_RUBY_WSTRING_ENCODING is given when compiling this binding.");
    }
    if (cptr && alloc)  {
      *alloc = SWIG_NEWOBJ;
      *cptr = %new_array(size, wchar_t);
      memmove(*cptr, cstr, RSTRING_LEN(tmp));
    }
    if(psize) *psize = size;

    return SWIG_OK;
  } else {
    return SWIG_TypeError;
  }
}
}

%fragment("SWIG_FromWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor",fragment="SWIG_FromCharPtrAndSize") {
SWIGINTERNINLINE VALUE 
SWIG_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  if (carray && size <= LONG_MAX) {
    VALUE ret = rb_str_new( (const char*)carray, %numeric_cast(size*sizeof(wchar_t),long) );
    rb_encoding* new_enc = rb_default_internal_encoding();

    rb_enc_associate(ret, rb_to_encoding(rb_str_new_cstr( SWIG_RUBY_WSTRING_ENCODING )) );

    if( !new_enc ) {
      new_enc = rb_to_encoding(rb_str_new_cstr( SWIG_RUBY_INTERNAL_ENCODING ));
    }
    return rb_str_conv_enc(ret, rb_enc_get(ret), new_enc);
  } else {
    return Qnil;
  }
}
}


