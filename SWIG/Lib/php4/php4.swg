/*
 * php4.swg
 *
 * PHP 4 configuration file
 *
 */

%runtime "common.swg"		// common type checking code
%runtime "php4run.swg"		// Php4 runtime functions

/* Typemaps for input parameters */

%typemap(in) int, unsigned int, unsigned short, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE
	"convert_to_long_ex($input);
	$1 = ($1_ltype) Z_LVAL_PP($input);";

%typemap(in) char
	"convert_to_string_ex($input);
	$1 = ($1_ltype) *Z_STRVAL_PP($input);";

%typemap(in) float,double
	"convert_to_double_ex($input);
	$1 = ($1_ltype) Z_DVAL_PP($input);";

%typemap(in) char *
	"convert_to_string_ex($input);
	$1 = ($1_ltype) Z_STRVAL_PP($input);";

%typemap(in) SWIGTYPE *, SWIGTYPE [], SWIGTYPE & {
	if(SWIG_ConvertPtr(*$input, (void **) &$1, $1_descriptor) < 0) {
	  zend_error(E_ERROR, "Type error in argument $argnum of $symname. Expected ", $1_descriptor->name);
	}
}
	
%typemap(in) void * {
	if(SWIG_ConvertPtr(*$input, (void **) $1, 0) < 0) {
	  zend_error(E_ERROR, "Type error in argument $argnum of $symname. Expected ", $1_descriptor->name);
	}
}

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE {
	$&1_ltype argp;
	if(SWIG_ConvertPtr(*$input, (void **) argp, $&1_descriptor) < 0) {
	  zend_error(E_ERROR, "Type error in argument $argnum of $symname. Expected ", $&1_descriptor->name);
	}
}

/* Typemap for output values */

%typemap(out) int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE
	"RETURN_LONG($1);";

%typemap(out) float, double
	"RETURN_DOUBLE($1);";

%typemap(out) char {
	"char ctemp[2];
	ctemp[0] = $1;
	ctemp[1] = 0;
	RETURN_STRING(ctemp, 1);";
}

%typemap(out) char *
	"RETURN_STRING($1, 1);";

%typemap(out) SWIGTYPE *, SWIGTYPE [], SWIGTYPE &
	"SWIG_SetPointerZval(return_value, (void *)$1, $1_descriptor);";

%typemap(out) SWIGTYPE
#ifdef __cplusplus
{
  $&1_ltype resultobj = new $1_ltype($1);
  SWIG_SetPointerZval(return_value, (void *)resultobj, $&1_descriptor);
}
#else
{
  $&1_ltype resultobj = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultobj, &$1, sizeof($1_type));
  SWIG_SetPointerZval(return_value, (void *)resultobj, $&1_descriptor);
}
#endif

%typemap(out) void "";

/* Typemap for character array returns */

%typemap(out) char [ANY] {
	char *s;
	s = estrdup($1);
	RETURN_STRING(s, 1);
}

/* Typemaps for constants */

%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
	"REGISTER_LONG_CONSTANT( \"$symname\", $value, CONST_CS);";

%typemap(consttab) float, double
	"REGISTER_DOUBLE_CONSTANT(\"$symname\", $value, CONST_CS);";

%typemap(consttab) char, char *
	"REGISTER_STRING_CONSTANT(\"$symname\", \"$value\", CONST_CS | CONST_PERSISTENT);";

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
	char *cp;
	SWIG_SetPointerChar(&cp, (void*)$value, $descriptor);
	REGISTER_STRING_CONSTANT("$symname", cp, CONST_CS | CONST_PERSISTENT);
}
