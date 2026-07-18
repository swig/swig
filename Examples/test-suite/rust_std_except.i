%module rust_std_except

%include <std_except.i>

%inline %{
#include <stdexcept>

#if __cplusplus >= 201103L
#define SWIG_RUST_THROW_OUT_OF_RANGE noexcept(false)
#else
#define SWIG_RUST_THROW_OUT_OF_RANGE throw (std::out_of_range)
#endif

int rust_no_throw() SWIG_RUST_THROW_OUT_OF_RANGE {
  return 7;
}

int rust_throw_out_of_range() SWIG_RUST_THROW_OUT_OF_RANGE {
  throw std::out_of_range("rust out of range");
}
%}
