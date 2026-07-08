/* -----------------------------------------------------------------------------
 * std_except.i
 *
 * Typemaps used by the STL wrappers that throw exceptions. These typemaps are
 * used when methods are declared with an STL exception specification, such as
 *   size_t at() const throw (std::out_of_range);
 * ----------------------------------------------------------------------------- */

%{
#include <typeinfo>
#include <stdexcept>
%}

#ifndef SWIG_RUST_THROW_OUT_OF_RANGE
#if __cplusplus >= 201703L
#define SWIG_RUST_THROW_OUT_OF_RANGE noexcept(false)
#else
#define SWIG_RUST_THROW_OUT_OF_RANGE throw (std::out_of_range)
#endif
#endif

namespace std
{
  %ignore exception;
  struct exception {};
}

%typemap(throws, canthrow=1) std::bad_cast          "SWIG_RustSetPendingException(\"std::bad_cast\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::bad_exception     "SWIG_RustSetPendingException(\"std::bad_exception\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::domain_error      "SWIG_RustSetPendingException(\"std::domain_error\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::exception         "SWIG_RustSetPendingException(\"std::exception\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::invalid_argument  "SWIG_RustSetPendingException(\"std::invalid_argument\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::length_error      "SWIG_RustSetPendingException(\"std::length_error\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::logic_error       "SWIG_RustSetPendingException(\"std::logic_error\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::out_of_range      "SWIG_RustSetPendingException(\"std::out_of_range\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::overflow_error    "SWIG_RustSetPendingException(\"std::overflow_error\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::range_error       "SWIG_RustSetPendingException(\"std::range_error\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::runtime_error     "SWIG_RustSetPendingException(\"std::runtime_error\", $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::underflow_error   "SWIG_RustSetPendingException(\"std::underflow_error\", $1.what());\n return $null;"
