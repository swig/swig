/* -----------------------------------------------------------------------------
 * This file provides backwards compatible enum wrapping. SWIG versions 1.3.21
 * and earlier wrapped global enums with constant integers in the module class
 * or Constants interface. Enums declared within a C++ class were wrapped by
 * constant integers in the Java proxy class.
 * ----------------------------------------------------------------------------- */

%typemap(jni) enum SWIGTYPE "jint"
%typemap(jtype) enum SWIGTYPE "int"
%typemap(jstype) enum SWIGTYPE "int"

%typemap(in) enum SWIGTYPE  %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE  %{ $result = (jint)$1; %}

%typemap(directorin, descriptor="I") enum SWIGTYPE    "$input = (jint) $1;"
%typemap(javadirectorin) enum SWIGTYPE "$jniinput"
%typemap(javadirectorout) enum SWIGTYPE "$javacall"

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE %{
  (void)$1;
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown");
%}

%typemap(javain) enum SWIGTYPE "$javainput"
%typemap(javaout) enum SWIGTYPE {
    return $jnicall;
  }

%typemap(javaclassmodifiers) enum SWIGTYPE ""
%typemap(javabody) enum SWIGTYPE ""

%javaenum(simple);

