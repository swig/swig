#ifndef SWIG_STD_COMPLEX_I_
#define SWIG_STD_COMPLEX_I_

%{
#include <complex> 
%}

%include "complex_common.i"


/* defining the complex as/from converters */

%swig_cplxdbl_conv(std::complex<double>, StdCplxDbl,
		   std::complex<double>, std::real, std::imag)

%swig_cplxflt_conv(std::complex<float>,  StdCplxFlt,
		   std::complex<float>,  std::real, std::imag)

/* declaring the typemaps */

%typemap_asfrom(std::complex<double>, CPLXDBL, 
		SWIG_PyObj_AsStdCplxDbl, SWIG_PyObj_FromStdCplxDbl);

%typemap_asfrom(std::complex<float>,  CPLXFLT, 
		SWIG_PyObj_AsStdCplxFlt, SWIG_PyObj_FromStdCplxFlt);


#endif //SWIG_STD_COMPLEX_I_
