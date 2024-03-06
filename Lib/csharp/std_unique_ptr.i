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
%typemap (ctype) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && "void *"
%typemap (imtype, out="System.IntPtr") std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && "global::System.Runtime.InteropServices.HandleRef"
%typemap (cstype) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && "$typemap(cstype, TYPE)"

%typemap(in) std::unique_ptr< TYPE >
%{ $1.reset((TYPE *)$input); %}
%typemap(in) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > &&
%{ $*1_ltype $1_uptr((TYPE *)$input);
  $1 = &$1_uptr; %}
%typemap(in, fragment="SwigNoDeleteUniquePtr") const std::unique_ptr< TYPE > &
%{ swig::NoDeleteUniquePtr< TYPE > $1_ndup((TYPE *)$input);
$1 = &$1_ndup.uptr; %}

%typemap(csin) std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && "$typemap(cstype, TYPE).swigRelease($csinput)"
%typemap(csin) const std::unique_ptr< TYPE > & "$typemap(cstype, TYPE).getCPtr($csinput)"

%typemap (out) std::unique_ptr< TYPE > %{
  $result = (void *)$1.release();
%}
%typemap (out) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && %{
  $result = (void *)$1->get();
%}


%typemap(csout, excode=SWIGEXCODE) std::unique_ptr< TYPE > {
    System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && {
    System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, false);$excode
    return ret;
  }


%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *") std::unique_ptr< TYPE >, std::unique_ptr< TYPE > &, std::unique_ptr< TYPE > && ""

%template() std::unique_ptr< TYPE >;
%enddef
