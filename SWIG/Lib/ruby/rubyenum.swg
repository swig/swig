/* ------------------------------------------------------------
 *  Enums 
 * ------------------------------------------------------------ */

/* --- Input typemaps --- */
%typemap(in) enum SWIGTYPE   "$1 = ($1_ltype) NUM2INT($input);";

/* --- Output typemaps --- */
%typemap(out) enum SWIGTYPE "$result = INT2NUM($1);";

/* --- Variable Input --- */

%{
static void SWIG_AsVal(VALUE obj, int *val)
{
    *val = (int) NUM2INT(obj);
}
%}

%typemap(varin) enum SWIGTYPE {
    if (sizeof(int) != sizeof($1)) {
        rb_raise(rb_eTypeError, "enum variable '$name' can not be set.");
    }
    SWIG_AsVal($input, (int *)(void *) &$1);
}

/* --- Variable Output --- */

%typemap(varout) enum SWIGTYPE "$result = INT2NUM($1);";

/* --- Constants --- */
%typemap(constant) enum SWIGTYPE "rb_define_const($module,\"$symname\", INT2NUM($1));";

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_INTEGER) enum SWIGTYPE
{
  $1 = ((TYPE($input) == T_FIXNUM) || (TYPE($input) == T_BIGNUM)) ? 1 : 0;
}

/* ------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------ */


