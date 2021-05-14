/* -------------------------------------------------------------------------
 * ccomplex.i
 * ------------------------------------------------------------------------- */

%{
#include <complex.h>

#define SWIG_ccomplex_construct(REAL, IMAG) ((REAL) + I * (IMAG))
%}

/* TODO: SWIG's parser defines "complex" but does *not* define _Complex;
 * this is the reverse of the standard. */
#define _Complex complex

%define %fortran_typemap_ccomplex(CTYPE, FKIND)
  %fortran_typemap_complex(complex CTYPE, SWIG_ccomplex_construct, CTYPE, FKIND)
%enddef

%fortran_typemap_ccomplex(float, C_FLOAT_COMPLEX)
%fortran_typemap_ccomplex(double, C_DOUBLE_COMPLEX)

%typemap(out, fragment="SWIG_complex_float", noblock=1) complex float
{$result = SWIG_create_complex_float(crealf($1), cimagf($1));}
%typemap(out, fragment="SWIG_complex_double", noblock=1) complex double
{$result = SWIG_create_complex_double(creal($1), cimag($1));}


