/* -----------------------------------------------------------------------------
 * This file provides backwards compatible enum wrapping. SWIG versions 1.3.21
 * and earlier wrapped global enums with constant integers in the module
 * class. Enums declared within a C++ class were wrapped by constant integers
 * in the C# proxy class.
 * ----------------------------------------------------------------------------- */

%typemap(ctype) enum SWIGTYPE "int"
%typemap(imtype) enum SWIGTYPE "int"
%typemap(cstype) enum SWIGTYPE "int"

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = $1; %}

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE %{
  (void)$1;
  SWIG_CSharpThrowException(SWIG_CSharpException, "C++ $1_type exception thrown");
%}

%typemap(csin) enum SWIGTYPE "$csinput"
%typemap(csout) enum SWIGTYPE {
    return $imcall;
  }

%typemap(csvarout) enum SWIGTYPE %{
    get {
      return $imcall;
    } %}

%typemap(csclassmodifiers) enum SWIGTYPE ""

%typemap(csbody) enum SWIGTYPE ""

%csenum(simple);

