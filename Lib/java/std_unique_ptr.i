/* -----------------------------------------------------------------------------
 * std_unique_ptr.i
 *
 * SWIG library file for handling std::unique_ptr.
 *
 * Returning a std::unique_ptr from a wrapped function:
 *   Memory ownership is passed (moved) from the std::unique_ptr in the C++ layer
 *   to the proxy class when returning a std::unique_ptr by value from a function.
 *   Memory ownership is not moved when returning by any sort of reference.
 *
 * Passing a std::unique_ptr as a parameter to a wrapped function:
 *   Memory ownership is passed from the proxy class to the std::unique_ptr in the
 *   C++ layer when passed as a parameter by value, rvalue reference or non-const
 *   lvalue reference. Memory ownership is not transferred when passing by const
 *   lvalue reference.
 * ----------------------------------------------------------------------------- */

%include <unique_ptr.swg>

%define %unique_ptr(TYPE)

%typemap (jni) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&  "jlong"
%typemap (jtype) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&  "long"
%typemap (jstype) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&  "$typemap(jstype, TYPE)"

%typemap(in) std::unique_ptr< TYPE > (TYPE *unique_temp)
%{ unique_temp = *(TYPE **)&$input;
  $1.reset(unique_temp); %}
%typemap(in) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&
%{ $*1_ltype $1_uptr((TYPE *)$input);
  $1 = &$1_uptr; %}
%typemap(in, fragment="SwigNoDeleteUniquePtr") const std::unique_ptr< TYPE > &
%{ swig::NoDeleteUniquePtr< TYPE > $1_ndup((TYPE *)$input);
$1 = &$1_ndup.uptr; %}

%typemap(javain) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&  "$typemap(jstype, TYPE).swigRelease($javainput)"
%typemap(javain) const std::unique_ptr< TYPE > &  "$typemap(jstype, TYPE).getCPtr($javainput)"

%typemap (out) std::unique_ptr< TYPE > %{
  jlong lpp = 0;
  *(TYPE **) &lpp = $1.release();
  $result = lpp;
%}
%typemap (out) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && %{
  jlong lpp = 0;
  *(TYPE **) &lpp = $1->get();
  $result = lpp;
%}


%typemap(javaout) std::unique_ptr< TYPE > {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, false);
  }

%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *") std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && ""

%template() std::unique_ptr< TYPE >;
%enddef
