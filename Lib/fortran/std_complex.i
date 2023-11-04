/* -------------------------------------------------------------------------
 * std_complex.i
 * ------------------------------------------------------------------------- */

%{
#include <complex>
%}

namespace std {
  %naturalvar complex;
  template<typename T> class complex;
}

%define %fortran_typemap_std_complex(CTYPE, FKIND)
  %template() std::complex<CTYPE>;
  %naturalvar std::complex<CTYPE>;
  %fortran_typemap_complex(std::complex<CTYPE>, std::complex<CTYPE>, CTYPE, FKIND)

  %typemap(out, fragment="SWIG_complex_"{CTYPE}, noblock=1) std::complex<CTYPE>
{$result = SWIG_create_complex_ ## CTYPE($1.real(), $1.imag());}
  %typemap(out, noblock=1) const std::complex<CTYPE>&
{$result = SWIG_create_complex_ ## CTYPE($1->real(), $1->imag());}

%enddef

%fortran_typemap_std_complex(float, C_FLOAT_COMPLEX)
%fortran_typemap_std_complex(double, C_DOUBLE_COMPLEX)
