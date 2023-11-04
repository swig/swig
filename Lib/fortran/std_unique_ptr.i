/* -----------------------------------------------------------------------------
 * std_unique_ptr.i
 *
 * SWIG library file for handling std::unique_ptr.
 * Memory ownership is passed from the std::unique_ptr C++ layer to the proxy
 * class when returning a std::unique_ptr from a function.
 * Memory ownership is passed from the proxy class to the std::unique_ptr in the
 * C++ layer when passed as a parameter to a wrapped function.
 * ----------------------------------------------------------------------------- */

%define %unique_ptr(TYPE)

// Assignment modifies the proxy classes
%typemap(imtype, in="type(SwigClassWrapper), intent(inout)", fragment="SwigClassWrapper_f") std::unique_ptr< TYPE >
  "type(SwigClassWrapper)"
%typemap(ftype, in="$typemap(ftype, " #TYPE "*), intent(inout)", noblock=1) std::unique_ptr< TYPE >
  {$typemap(ftype, TYPE*)}

%typemap(in) std::unique_ptr< TYPE >
%{ $1.reset((TYPE *)$input); %}

%typemap(fin, noblock=1) std::unique_ptr< TYPE > {
  $1 = $input%swigdata
  $input%swigdata%cptr = C_NULL_PTR
}

%typemap(out) std::unique_ptr< TYPE > %{
 $result.cptr = $1.release();
 $result.cmemflags = SWIG_MEM_OWN | SWIG_MEM_RVALUE;
%}

%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *") std::unique_ptr< TYPE > ""

%template() std::unique_ptr< TYPE >;
%enddef

namespace std {
  template <class T> class unique_ptr {};
}
