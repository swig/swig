/* ------------------------------------------------------------
 *  Enums 
 * ------------------------------------------------------------ */

/* --- Input typemaps --- */
%typemap(in) enum SWIGTYPE   "$1 = ($1_ltype) NUM2INT($input);";

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
        "temp = ($*1_ltype) NUM2INT($input);
         $1 = &temp;";


%typemap(directorout) enum SWIGTYPE "$result = ($1_ltype) NUM2INT($input);";
%typemap(directorout,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const enum SWIGTYPE &
%{ static $*1_ltype temp = ($*1_ltype) NUM2INT($input);
   $result = &temp; %}

/* --- Output typemaps --- */
%typemap(out) enum SWIGTYPE "$result = INT2NUM($1);";

%typemap(out) const enum SWIGTYPE & "$result = INT2NUM((long) *($1));";

%typemap(directorin) enum SWIGTYPE "$input = INT2NUM($1);";
%typemap(directorin) const enum SWIGTYPE& "$input = INT2NUM($1);";

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

%typecheck(SWIG_TYPECHECK_INTEGER) enum SWIGTYPE, const enum SWIGTYPE &
{
  $1 = ((TYPE($input) == T_FIXNUM) || (TYPE($input) == T_BIGNUM)) ? 1 : 0;
}

/* ------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------ */

%typemap(throws) enum SWIGTYPE
    "(void)$1; rb_exc_raise(rb_exc_new3(rb_eRuntimeError, rb_obj_as_string(INT2NUM($1))));"

