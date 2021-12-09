%define %pass_by_ref( TYPE, PHP_TYPE, CONVERT_IN, CONVERT_OUT )
%typemap(in,byref=1,phptype=PHP_TYPE) TYPE *REF ($*1_ltype tmp),
             TYPE &REF ($*1_ltype tmp)
%{
  if (Z_ISREF($input)) {
    CONVERT_IN(tmp, $*1_ltype, $input);
    $1 = &tmp;
  } else {
    zend_type_error(SWIG_PHP_Arg_Error_Msg($argnum, Expected a reference));
  }
%}
%typemap(argout) TYPE *REF,
                 TYPE &REF
%{
  if (Z_ISREF($input)) {
    CONVERT_OUT(Z_REFVAL($input), tmp$argnum);
  }
%}
%enddef

%pass_by_ref( size_t, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );

%pass_by_ref( signed int, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );
%pass_by_ref( int, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );
%pass_by_ref( unsigned int, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );

%pass_by_ref( signed short, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );
%pass_by_ref( short, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );
%pass_by_ref( unsigned short, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );

%pass_by_ref( signed long, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );
%pass_by_ref( long, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );
%pass_by_ref( unsigned long, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );

%pass_by_ref( signed char, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );
%pass_by_ref( char, "MAY_BE_STRING", CONVERT_CHAR_IN, ZVAL_STRING );
%pass_by_ref( unsigned char, "MAY_BE_LONG", CONVERT_INT_IN, ZVAL_LONG );

%pass_by_ref( float, "MAY_BE_DOUBLE", CONVERT_FLOAT_IN, ZVAL_DOUBLE );
%pass_by_ref( double, "MAY_BE_DOUBLE", CONVERT_FLOAT_IN, ZVAL_DOUBLE );

%pass_by_ref( char *, "MAY_BE_STRING", CONVERT_CHAR_IN, ZVAL_STRING );
