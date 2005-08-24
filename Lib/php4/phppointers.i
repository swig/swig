%define %pass_by_ref( TYPE, CONVERT_IN, CONVERT_OUT )
%typemap(in) TYPE * ($*1_ltype tmp),
             TYPE & ($*1_ltype tmp)
{
  /* First Check for SWIG wrapped type */
  if ( ZVAL_IS_NULL( *$input ) ) {
      $1 = 0;
  } else if ( PZVAL_IS_REF( *$input ) ) {
      /* Not swig wrapped type, so we check if it's a PHP reference type */
        CONVERT_IN( tmp, $*1_ltype, $input );
      $1 = &tmp;
  } else {
        SWIG_PHP_Error( E_ERROR, SWIG_PHP_Arg_Error_Msg($argnum, Excpeted a reference) );
  }
}
%typemap(argout) TYPE *,
                 TYPE & {
  CONVERT_OUT(*$input, tmp$argnum );
}
%enddef

%pass_by_ref( int, CONVERT_INT_IN, ZVAL_LONG );
%pass_by_ref( double, CONVERT_FLOAT_IN, ZVAL_DOUBLE );