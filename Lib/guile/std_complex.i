/*
 *  STD C++ complex typemaps
 */

%{
#include <complex> 
%}

namespace std {
  %naturalvar complex;
  template<typename T> class complex;
  %template() complex<double>;
}

%typemap(in) std::complex<double> {
  $1 = std::complex<double>(scm_to_double(scm_real_part($input)),
                            scm_to_double(scm_imag_part($input)));
}

%typemap(out) std::complex<double> {
  $result = scm_make_rectangular(scm_from_double($1.real()),
                                 scm_from_double($1.imag()));
}
