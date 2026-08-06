/* -----------------------------------------------------------------------------
 * std_complex.i
 *
 * Typemaps for handling std::complex<float> and std::complex<double> in Rust.
 * ----------------------------------------------------------------------------- */

%{
#include <complex>
%}

%fragment("SWIG_RustComplex", "header") %{
#ifdef __clang__
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"
#endif

typedef struct SWIG_RustComplex {
  double real;
  double imag;
  SWIG_RustComplex(double real = 0.0, double imag = 0.0) : real(real), imag(imag) {
  }
} SWIG_RustComplex;

SWIGINTERN SWIG_RustComplex SWIG_RustCreateComplex(double real, double imag) {
  return SWIG_RustComplex(real, imag);
}
%}

%pragma(rust) modulecode=%{
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct RustComplex {
  pub real: c_double,
  pub imag: c_double,
}
%}

namespace std {
template<class T> class complex {
public:
  complex(T re = T(), T im = T());
  T real() const;
  T imag() const;
};
}

%define SWIG_RUST_COMPLEX_TYPEMAPS(T)
%typemap(ctype, fragment="SWIG_RustComplex") std::complex<T>, const std::complex<T> & "SWIG_RustComplex"
%typemap(imtype) std::complex<T>, const std::complex<T> & "RustComplex"
%typemap(rusttype) std::complex<T>, const std::complex<T> & "RustComplex"

%typemap(in) std::complex<T>
%{ $1 = std::complex<T>((T)$input.real, (T)$input.imag); %}

%typemap(in) const std::complex<T> & ($*1_ltype temp)
%{ temp = std::complex<T>((T)$input.real, (T)$input.imag);
   $1 = &temp; %}

%typemap(out, null="SWIG_RustCreateComplex(0.0, 0.0)") std::complex<T>
%{ $result = SWIG_RustCreateComplex((double)$1.real(), (double)$1.imag()); %}

%typemap(out, null="SWIG_RustCreateComplex(0.0, 0.0)") const std::complex<T> &
%{ $result = SWIG_RustCreateComplex((double)$1->real(), (double)$1->imag()); %}

%typemap(rustin) std::complex<T>, const std::complex<T> & "$rustinput"
%typemap(rustout) std::complex<T>, const std::complex<T> & {
  let ret = $imcall;
  rust_check_exception();
  ret
}

%template() std::complex<T>;
%enddef

#ifndef SWIG_RUST_STD_COMPLEX_FLOAT
SWIG_RUST_COMPLEX_TYPEMAPS(float)
#endif

#ifndef SWIG_RUST_STD_COMPLEX_DOUBLE
SWIG_RUST_COMPLEX_TYPEMAPS(double)
#endif
