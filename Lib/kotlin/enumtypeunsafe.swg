/* -----------------------------------------------------------------------------
 * enumtypeunsafe.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by integers values.
 * Each enum has an equivalent class named after the enum and the enum items are
 * wrapped by constant integers within this class. The enum items are not
 * typesafe as they are all integers.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(jni) const enum SWIGTYPE & "jint"
%typemap(ktype) const enum SWIGTYPE & "Int"
%typemap(kstype) const enum SWIGTYPE & "Int"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE &  %{ $result = (jint)*$1; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum SWIGTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin, descriptor="I") const enum SWIGTYPE & "$input = (jint)$1;"
%typemap(kdirectorin) const enum SWIGTYPE & "$jniinput"
%typemap(kdirectorout) const enum SWIGTYPE & "$kotlincall"

%typecheck(SWIG_TYPECHECK_INT32) const enum SWIGTYPE & ""

%typemap(throws) const enum SWIGTYPE &
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown"); %}

%typemap(kin) const enum SWIGTYPE & "$kotlininput"
%typemap(kout) const enum SWIGTYPE & {
    return $jnicall;
  }


// enum SWIGTYPE typemaps
%typemap(jni) enum SWIGTYPE "jint"
%typemap(ktype) enum SWIGTYPE "Int"
%typemap(kstype) enum SWIGTYPE "Int"

%typemap(in) enum SWIGTYPE  %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE  %{ $result = (jint)$1; %}

%typemap(directorout) enum SWIGTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin, descriptor="I") enum SWIGTYPE "$input = (jint) $1;"
%typemap(kdirectorin) enum SWIGTYPE "$jniinput"
%typemap(kdirectorout) enum SWIGTYPE "$kotlincall"

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown"); %}

%typemap(kin) enum SWIGTYPE "$kotlininput"
%typemap(kout) enum SWIGTYPE {
    return $jnicall;
  }

// The enum value constants are emitted into a companion object which is opened by the
// enum declaration and closed again by the kbody typemap.
%typemap(kclassmodifiers) enum SWIGTYPE "class"
%typemap(kbase)           enum SWIGTYPE ""
%typemap(kcode)           enum SWIGTYPE ""
%typemap(kimports)        enum SWIGTYPE ""
%typemap(kinterfaces)     enum SWIGTYPE ""
%typemap(kbody)           enum SWIGTYPE "  }\n"

%kotlinenum(typeunsafe);

