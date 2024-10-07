
%define CONVERT_BOOL_IN(lvar,t,invar)
  lvar = (t) zval_is_true(&invar);
%enddef

%define CONVERT_INT_IN(lvar,t,invar)
  lvar = (t) zval_get_long(&invar);
%enddef

%define CONVERT_LONG_LONG_IN(lvar,t,invar)
  switch (Z_TYPE(invar)) {
      case IS_DOUBLE:
          lvar = (t) Z_DVAL(invar);
          break;
      case IS_STRING: {
          char * endptr;
          errno = 0;
          lvar = (t) strtoll(Z_STRVAL(invar), &endptr, 10);
          if (*endptr == '\0' && !errno) break;
      }
      /* FALL THRU */
      default:
          lvar = (t) zval_get_long(&invar);
  }
%enddef

%define CONVERT_UNSIGNED_LONG_LONG_IN(lvar,t,invar)
  switch (Z_TYPE(invar)) {
      case IS_DOUBLE:
          lvar = (t) Z_DVAL(invar);
          break;
      case IS_STRING: {
          char * endptr;
          errno = 0;
          lvar = (t) strtoull(Z_STRVAL(invar), &endptr, 10);
          if (*endptr == '\0' && !errno) break;
      }
      /* FALL THRU */
      default:
          lvar = (t) zval_get_long(&invar);
  }
%enddef

%define CONVERT_INT_OUT(lvar,invar)
  lvar = (t) zval_get_long(&invar);
%enddef

%define CONVERT_FLOAT_IN(lvar,t,invar)
  lvar = (t) zval_get_double(&invar);
%enddef

%define CONVERT_CHAR_IN(lvar,t,invar)
  convert_to_string(&invar);
  lvar = (t) Z_STRVAL(invar)[0];
%enddef

%define CONVERT_STRING_IN(lvar,t,invar)
  if (Z_ISNULL(invar)) {
    lvar = (t) 0;
  } else {
    convert_to_string(&invar);
    lvar = (t) Z_STRVAL(invar);
  }
%enddef

%define %pass_by_val( TYPE, PHP_TYPE, CONVERT_IN )
%typemap(in, phptype=PHP_TYPE) TYPE
%{
  CONVERT_IN($1,$1_ltype,$input);
%}
%typemap(in, phptype=PHP_TYPE) const TYPE & ($*1_ltype temp)
%{
  CONVERT_IN(temp,$*1_ltype,$input);
  $1 = &temp;
%}
%typemap(directorout) TYPE
%{
  CONVERT_IN($result, $1_ltype, *$input);
%}
%typemap(directorout) const TYPE &
%{
  $*1_ltype swig_val;
  CONVERT_IN(swig_val, $*1_ltype, *$input);
  $1_ltype temp = new $*1_ltype(swig_val);
  swig_acquire_ownership(temp);
  $result = temp;
%}
%typemap(directorfree) const TYPE &
%{
  if (director) {
    director->swig_release_ownership(%as_voidptr($input));
  }
%}
%enddef

#define SWIG_AppendOutput(result, obj)  SWIG_Php_AppendOutput(result, obj, $isvoid)

/* Deprecated (since 4.3.0) backwards compatibility macro */
#define t_output_helper SWIG_AppendOutput

/* Deprecated fragment */
%fragment("t_output_helper","header") {}
