/* -----------------------------------------------------------------------------
 * Include this file in order for C/C++ enums to be wrapped by integers values.
 * Each enum has an equivalent class named after the enum and the enum items are
 * wrapped by constant integers within this class. The enum items are not
 * typesafe as they are all integers.
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

%typemap(javain) enum SWIGTYPE "$javainput.swigValue()"
%typemap(javaout) enum SWIGTYPE {
    return $javaclassname.swigToEnum($jnicall);
  }

%typemap(throws) enum SWIGTYPE {
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown");
}

%typemap(javain) enum SWIGTYPE "$javainput"
%typemap(javaout) enum SWIGTYPE {
    return $jnicall;
  }

// '$static' will be replaced with either 'static' or nothing depending on whether the enum is an inner Java class or not
%typemap(javaclassmodifiers) enum SWIGTYPE "public $static class"
%typemap(javagetcptr) enum SWIGTYPE ""

%javaenum(typeunsafe);

