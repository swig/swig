#ifndef __swig_std_complex_i__
#define __swig_std_complex_i__

#ifdef SWIG

%{
#include <complex>
%} 

namespace std 
{
  template <class T> class complex;  
  
  %define specialize_std_complex(T)
  
  %typemap(in) complex<T> {
    if (PyComplex_Check($input)) {
      $1 = std::complex<T>(PyComplex_RealAsDouble($input),
			   PyComplex_ImagAsDouble($input));
    } else if (PyFloat_Check($input)) {
      $1 = std::complex<T>(PyFloat_AsDouble($input), 0);
    } else if (PyInt_Check($input)) {
      $1 = std::complex<T>(PyInt_AsLong($input), 0);
    }
    else {
      PyErr_SetString(PyExc_TypeError,"Expected a complex");
      SWIG_fail;
    }
  }  
  
  %typemap(in) const complex<T>& (std::complex<T> temp) {
    if (PyComplex_Check($input)) {
      temp = std::complex<T>(PyComplex_RealAsDouble($input),
			     PyComplex_ImagAsDouble($input));
      $1 = &temp;
    } else if (PyFloat_Check($input)) {
      temp = std::complex<T>(PyFloat_AsDouble($input), 0);
      $1 = &temp;
    } else if (PyInt_Check($input)) {
      temp = std::complex<T>(PyInt_AsLong($input), 0);
      $1 = &temp;
    } else {	
      PyErr_SetString(PyExc_TypeError,"Expected a complex");
      SWIG_fail;
    }
  }
  
  %typemap(out) complex<T> {
    $result = PyComplex_FromDoubles($1.real(), $1.imag());
  }
  
  %typemap(out) const complex<T> & {
    $result = PyComplex_FromDoubles($1->real(), $1->imag());
  }

  %enddef  
     
  specialize_std_complex(double);
  specialize_std_complex(float);
}
  
#endif // SWIG

#endif //__swig_std_complex_i__
