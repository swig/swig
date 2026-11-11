/* -----------------------------------------------------------------------------
 * ccomplex.i
 *
 * C complex typemaps
 * ISO C99:  7.3 Complex arithmetic <complex.h>
 * ----------------------------------------------------------------------------- */


%include <javascriptcomplex.swg>

%{
#include <complex.h>
#include <float.h>
/* __imag__ is a GNU/Clang extension that works on C++ */
SWIGINTERN SWIGINLINE _Complex SWIG_get_imaginary_unit() {
  _Complex ret = 0; __imag__ ret = 1; return ret;
}
static const _Complex SWIG_C_I = SWIG_get_imaginary_unit();
extern "C" {double cimag(double _Complex);double creal(double _Complex);}
%}

#define complex _Complex
#define CCplxConst(r, i) ((r) + SWIG_C_I * (i))

%swig_cplxflt_convn(float _Complex, CCplxConst, creal, cimag);
%swig_cplxdbl_convn(double _Complex, CCplxConst, creal, cimag);
%swig_cplxdbl_convn(_Complex, CCplxConst, creal, cimag);

/* declaring the typemaps */
%typemaps_primitive(SWIG_TYPECHECK_CPLXFLT, float _Complex);
%typemaps_primitive(SWIG_TYPECHECK_CPLXDBL, double _Complex);
%typemaps_primitive(SWIG_TYPECHECK_CPLXDBL, _Complex);
