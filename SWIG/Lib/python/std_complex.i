#ifndef SWIG_STD_COMPLEX_I_
#define SWIG_STD_COMPLEX_I_

%include complex_common.i

%{
#include <complex> 
%}

/* defining the complex as/from converters */

%swig_cplxdbl_convn(std::complex<double>, 
		    std::complex<double>, std::real, std::imag)

%swig_cplxflt_convn(std::complex<float>, 
		    std::complex<float>, std::real, std::imag)


%typemap_primitive(SWIG_CCode(CPLXDBL), std::complex<double>);
%typemap_primitive(SWIG_CCode(CPLXFLT), std::complex<float>);


#endif //SWIG_STD_COMPLEX_I_
