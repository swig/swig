/* -----------------------------------------------------------------------------
 * std_auto_ptr.i
 *
 * std::auto_ptr<T> typemaps for Rust.
 * ----------------------------------------------------------------------------- */

%{
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#elif defined(__GNUC__)
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#endif
#define _LIBCPP_DISABLE_DEPRECATION_WARNINGS
#include <memory>
%}

%define %auto_ptr(TYPE...)
%typemap(ctype) std::auto_ptr<TYPE > "void *"
%typemap(imtype, out="*mut c_void") std::auto_ptr<TYPE > "*mut c_void"
%typemap(rusttype) std::auto_ptr<TYPE > "TYPE"

%typemap(in) std::auto_ptr<TYPE >
%{ $1.reset((TYPE *)$input); %}

%typemap(out) std::auto_ptr<TYPE >
%{ $result = (void *)$1.release(); %}

%typemap(rustin) std::auto_ptr<TYPE > "$rustinput.into_raw()"
%typemap(rustout) std::auto_ptr<TYPE > {
  let ptr = $imcall;
  rust_check_exception();
  TYPE::from_raw_owned_unchecked(ptr, true)
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *") std::auto_ptr<TYPE > ""

%template() std::auto_ptr<TYPE >;
%enddef

namespace std {
template<class T> class auto_ptr {
};
}
