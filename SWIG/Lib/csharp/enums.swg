/* -----------------------------------------------------------------------------
 * Include this file in order for C/C++ enums to be wrapped by proper C# enums.
 * Note that the PINVOKE layer handles the enum as an int.
 * ----------------------------------------------------------------------------- */

%typemap(ctype) enum SWIGTYPE "int"
%typemap(imtype) enum SWIGTYPE "int"
%typemap(cstype) enum SWIGTYPE "$csclassname"

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = $1; %}

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE %{
  SWIG_CSharpThrowException(SWIG_CSharpException, "C++ $1_type exception thrown");
%}

%typemap(csin) enum SWIGTYPE "(int)$csinput"
%typemap(csout) enum SWIGTYPE {
    return ($csclassname)$imcall;
  }

%typemap(csvarout) enum SWIGTYPE %{
    get {
      return ($csclassname)$imcall;
    } %}

%typemap(csclassmodifiers) enum SWIGTYPE "public enum"

%typemap(csbody) enum SWIGTYPE ""

%csenum(proper);

