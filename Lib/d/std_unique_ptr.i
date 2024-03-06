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
%typemap (ctype) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&  "void *"
%typemap (imtype) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&  "void*"
%typemap (dtype) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&  "$typemap(dtype, TYPE)"

%typemap(in) std::unique_ptr< TYPE >
%{ $1.reset((TYPE *)$input); %}
%typemap(in) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&
%{ $*1_ltype $1_uptr((TYPE *)$input);
  $1 = &$1_uptr; %}
%typemap(in, fragment="SwigNoDeleteUniquePtr") const std::unique_ptr< TYPE > &
%{ swig::NoDeleteUniquePtr< TYPE > $1_ndup((TYPE *)$input);
$1 = &$1_ndup.uptr; %}


%typemap(din,
  nativepointer="cast(void*)$dinput"
) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&  "$typemap(dtype, TYPE).swigRelease($dinput)"
%typemap(din,
  nativepointer="cast(void*)$dinput"
) const std::unique_ptr< TYPE > &  "$typemap(dtype, TYPE).swigGetCPtr($dinput)"

%typemap (out) std::unique_ptr< TYPE > %{
  $result = (void *)$1.release();
%}
%typemap (out) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && %{
  $result = (void *)$1->get();
%}


%typemap(dout, excode=SWIGEXCODE,
  nativepointer="{\n  auto ret = cast($dtype)$imcall;$excode\n  return ret;\n}"
) std::unique_ptr< TYPE > {
  void* cPtr = $imcall;
  $typemap(dtype, TYPE) ret = (cPtr is null) ? null : new $typemap(dtype, TYPE)(cPtr, true);$excode
  return ret;
}
%typemap(dout, excode=SWIGEXCODE,
  nativepointer="{\n  auto ret = cast($dtype)$imcall;$excode\n  return ret;\n}"
) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && {
  void* cPtr = $imcall;
  $typemap(dtype, TYPE) ret = (cPtr is null) ? null : new $typemap(dtype, TYPE)(cPtr, false);$excode
  return ret;
}


%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *") std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && ""

%template() std::unique_ptr< TYPE >;
%enddef
