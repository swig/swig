#ifndef SWIG_STD_COMPLEX_I_
#define SWIG_STD_COMPLEX_I_

%include "complex_common.i"


%{
#include <complex> 
%}

/* defining the complex as/from converters */

%swig_cplxdbl_conv(std::complex<double>, StdCplxDbl,
		   std::complex<double>, std::real, std::imag)

%swig_cplxflt_conv(std::complex<float>, StdCplxFlt,
		   std::complex<float>, std::real, std::imag)

/* declaring the typemaps */

%typemap_stype(std::complex<double>, CPLXDBL, StdCplxDbl);
%typemap_stype(std::complex<float>,  CPLXFLT, StdCplxFlt);


#endif //SWIG_STD_COMPLEX_I_
