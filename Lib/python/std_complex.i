#ifndef __swig_std_complex_i__
#define __swig_std_complex_i__

#ifdef SWIG

%{
#include <complex>

static inline int
SwigComplex_Check(PyObject *o)
{
  return (PyComplex_Check(o) || PyFloat_Check(o) || PyInt_Check(o)) ? 1 : 0;
}
 
template <class __Complex>
__Complex
SwigComplex_As(PyObject *o)
{
  if (PyComplex_Check(o)) {
    return __Complex(PyComplex_RealAsDouble(o), PyComplex_ImagAsDouble(o));
  } else if (PyFloat_Check(o)) {
    return __Complex(PyFloat_AsDouble(o), 0);
  } else if (PyInt_Check(o)) {
    return __Complex(PyInt_AsLong(o), 0);
  } else {
    PyErr_SetString(PyExc_TypeError, "Expecting a complex or compatible type");
    return __Complex(0,0);
  }
}

static inline std::complex<double>
SwigComplex_AsComplexDouble(PyObject *o)
{
  return SwigComplex_As<std::complex<double> >(o);
}
 
 
%}


%define swig_specialize_complex(Complex)
  
  %typecheck(SWIG_TYPECHECK_COMPLEX)
  Complex, const Complex&
  {
    $1 = SwigComplex_Check($input);
  }
  
  %typemap(in) Complex {
    $1 = SwigComplex_As< Complex >($input);
    if (PyErr_Occurred()) SWIG_fail;
  }  
  
  %typemap(in) const Complex& (Complex temp) {
    temp = SwigComplex_As< Complex >($input);
    if (PyErr_Occurred()) SWIG_fail;
    $1 = &temp;
  }
  
  %typemap(out) Complex {
    $result = PyComplex_FromDoubles($1.real(), $1.imag());
  }
  
  %typemap(out) const Complex & {
    $result = PyComplex_FromDoubles($1->real(), $1->imag());
  }
  
  // C++ proxy class typemaps

  %typemap(inv) complex<T> {
    $input =  PyComplex_FromDoubles($1_name.real(), $1_name.imag());
  }
  
  %typemap(inv) const complex<T> & {
    $inupt =  PyComplex_FromDoubles($1_name->real(), $1_name->imag());
  }
  
  %typemap(outv) complex<T> {
    if (PyComplex_Check($input)) {
      $result = std::complex<T>(PyComplex_RealAsDouble($input),
			   PyComplex_ImagAsDouble($input));
    } else if (PyFloat_Check($input)) {
      $result = std::complex<T>(PyFloat_AsDouble($input), 0);
    } else if (PyInt_Check($input)) {
      $result = std::complex<T>(PyInt_AsLong($input), 0);
    }
    else {
      throw SWIG_DIRECTOR_TYPE_MISMATCH("Expected a complex");
    }
  }  
  
  %typemap(outv) const complex<T>& (std::complex<T> temp) {
    if (PyComplex_Check($input)) {
      temp = std::complex<T>(PyComplex_RealAsDouble($input),
			     PyComplex_ImagAsDouble($input));
      $result = &temp;
    } else if (PyFloat_Check($input)) {
      temp = std::complex<T>(PyFloat_AsDouble($input), 0);
      $result = &temp;
    } else if (PyInt_Check($input)) {
      temp = std::complex<T>(PyInt_AsLong($input), 0);
      $result = &temp;
    } else {	
      throw SWIG_DIRECTOR_TYPE_MISMATCH("Expected a complex");
    }
  }
  

%enddef  
     
namespace std
{
  template <class T> class complex;  
}

swig_specialize_complex(std::complex<float>);
swig_specialize_complex(std::complex<double>);
  
#endif // SWIG

#endif //__swig_std_complex_i__
