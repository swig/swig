/* -------------------------------------------------------------------------
 * ccomplex.i
 * ------------------------------------------------------------------------- */

%{
#include <complex.h>

#define SWIG_ccomplex_construct(REAL, IMAG) ((REAL) + I * (IMAG))
%}

// Avoid substituting the fortran type 'complex' until we've set up the typemaps
#undef complex

%define %fortran_typemap_ccomplex(CTYPE, FKIND)
  %fortran_typemap_complex(CTYPE _Complex, SWIG_ccomplex_construct, CTYPE, FKIND)
%enddef

%fortran_typemap_ccomplex(float, C_FLOAT_COMPLEX)
%fortran_typemap_ccomplex(double, C_DOUBLE_COMPLEX)

%typemap(out, fragment="SWIG_complex_float", noblock=1) _Complex float
{$result = SWIG_create_complex_float(crealf($1), cimagf($1));}
%typemap(out, fragment="SWIG_complex_double", noblock=1) _Complex double
{$result = SWIG_create_complex_double(creal($1), cimag($1));}

/* Including <complex.h> defines 'complex' as _Complex */
#define complex _Complex

