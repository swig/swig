
%include complex_common.i

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

%swig_cplxflt_convn(float_complex, CCplxConst, creal, cimag);
%swig_cplxdbl_convn(double_complex, CCplxConst, creal, cimag);

/* declaring the typemaps */
%typemap_primitive(SWIG_TYPECHECK_CPLXFLT, float_complex);
%typemap_primitive(SWIG_TYPECHECK_CPLXDBL, double_complex);

/* empty complex. hack in the meantime */
%apply double_complex { complex };
%apply const double_complex& { const complex& };
%apply double_complex& { complex& };
%apply double_complex* { complex* };




