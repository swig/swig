#ifndef __python_ccomplex_i__
#define __python_ccomplex_i__

/*
 *  C complex wrap
 *  ISO C99:  7.3 Complex arithmetic        <complex.h>
 */

%{
#include <complex.h>
%}


/*
  the %{}% around these typedefs must be removed once
  swig parser supports 'float complex'...
*/
%{
  typedef float complex float_complex;
  typedef double complex double_complex;
%}


%include "complex_common.i"

#define CCOMPLEX(r, i) ((r) + I*(i))
%swig_cplxflt_conv(float_complex,  CCplxFlt, CCOMPLEX, creal, cimag)
%swig_cplxdbl_conv(double_complex, CCplxDbl, CCOMPLEX, creal, cimag)

/* declaring the typemaps */
%typemap_asfrom(float_complex,  CPLXFLT, 
		SWIG_PyObj_AsCCplxFlt, SWIG_PyObj_FromCCplxFlt);

%typemap_asfrom(double_complex, CPLXDBL, 
		SWIG_PyObj_AsCCplxDbl, SWIG_PyObj_FromCCplxDbl);

%apply double_complex { complex };



#endif //__python_ccomplex_i__
