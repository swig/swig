/* -----------------------------------------------------------------------------
 * This file provides backwards compatible enum wrapping. SWIG versions 1.3.21
 * and earlier wrapped global enums with constant integers in the module
 * class. Enums declared within a C++ class were wrapped by constant integers
 * in the C# proxy class.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(ctype) const enum SWIGTYPE & "int"
%typemap(imtype) const enum SWIGTYPE & "int"
%typemap(cstype) const enum SWIGTYPE & "int"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE & %{ $result = *$1; %}

%typecheck(SWIG_TYPECHECK_INT32) const enum SWIGTYPE & ""

%typemap(throws, canthrow=1) const enum SWIGTYPE & %{
  (void)$1;
  SWIG_CSharpThrowException(SWIG_CSharpException, "C++ $1_type exception thrown");
%}

%typemap(csin) const enum SWIGTYPE & "$csinput"
%typemap(csout, excode=SWIGEXCODE) const enum SWIGTYPE & {
    int ret = $imcall;$excode
    return ret;
  }

%typemap(csvarout) const enum SWIGTYPE & %{
    get {
      return $imcall;
    } %}


// enum SWIGTYPE typemaps
%typemap(ctype) enum SWIGTYPE "int"
%typemap(imtype) enum SWIGTYPE "int"
%typemap(cstype) enum SWIGTYPE "int"

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = $1; %}

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws, canthrow=1) enum SWIGTYPE %{
  (void)$1;
  SWIG_CSharpThrowException(SWIG_CSharpException, "C++ $1_type exception thrown");
%}

%typemap(csin) enum SWIGTYPE "$csinput"
%typemap(csout, excode=SWIGEXCODE) enum SWIGTYPE {
    int ret = $imcall;$excode
    return ret;
  }

%typemap(csvarout) enum SWIGTYPE %{
    get {
      return $imcall;
    } %}

%typemap(csbase)           enum SWIGTYPE ""
%typemap(csclassmodifiers) enum SWIGTYPE ""
%typemap(cscode)           enum SWIGTYPE ""
%typemap(csimports)        enum SWIGTYPE ""
%typemap(csinterfaces)     enum SWIGTYPE ""

%typemap(csbody) enum SWIGTYPE ""

%csenum(simple);

