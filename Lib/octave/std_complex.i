//
// std_complex.i - STL complex typemaps
//

%include <octcomplex.swg>

%header %{
#include <complex>
%}

// Define the complex as/from converters
%swig_cplxdbl_convn(std::complex<double>, std::complex<double>, std::real, std::imag)
%swig_cplxflt_convn(std::complex<float>,  std::complex<float>,  std::real, std::imag)

// Define the typemaps
%typemaps_primitive(%checkcode(CPLXDBL), std::complex<double>);
%typemaps_primitive(%checkcode(CPLXFLT), std::complex<float>);
