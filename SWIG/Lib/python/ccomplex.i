#ifndef __python_ccomplex_i__
#define __python_ccomplex_i__

%include "complex_common.i"

/*
 *  C complex wrap
 *  ISO C99:  7.3 Complex arithmetic <complex.h>
 */

%{
#include <complex.h>
%}

/*
*** swig workaround ***
  the %{}% around these typedefs must be removed once
  swig parser supports 'float complex'...
*/
%{
  typedef float complex float_complex;
  typedef double complex double_complex;
%}

/* C complex constructor */
#define CCplxConst(r, i) ((r) + I*(i))

%swig_cplxflt_conv(float_complex, CCplxFlt, 
		   CCplxConst, creal, cimag);

%swig_cplxdbl_conv(double_complex, CCplxDbl, 
		   CCplxConst, creal, cimag);

/* declaring the typemaps */
%typemap_stype(float_complex,  CPLXFLT, CCplxFlt);
%typemap_stype(double_complex, CPLXDBL, CCplxDbl);

%apply double_complex { complex };



#endif //__python_ccomplex_i__
