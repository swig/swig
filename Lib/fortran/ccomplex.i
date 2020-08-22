/* -------------------------------------------------------------------------
 * ccomplex.i
 * ------------------------------------------------------------------------- */

%{
#include <complex.h>

#define SWIG_ccomplex_construct(REAL, IMAG) ((REAL) + I * (IMAG))
%}

%define %fortran_typemap_ccomplex(CPLX_TYPE, CTYPE, FKIND)
  %fortran_typemap_complex(CPLX_TYPE, SWIG_ccomplex_construct, CTYPE, FKIND)
%enddef

#error "C complex numbers are not currently supported"
