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
  %fortran_typemap_complex(std::complex<CTYPE>, std::complex<CTYPE>, CTYPE, FKIND)
%enddef

%fortran_typemap_std_complex(float, C_FLOAT_COMPLEX)
%fortran_typemap_std_complex(double, C_DOUBLE_COMPLEX)
