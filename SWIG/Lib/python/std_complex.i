#ifndef SWIG_STD_COMPLEX_I_
#define SWIG_STD_COMPLEX_I_

#ifdef SWIG

%{
#include <complex>

static inline int
SwigComplex_Check(PyObject *o)
{
  return PyComplex_Check(o) || PyFloat_Check(o) || PyInt_Check(o) || PyLong_Check(o);
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
  } else if (PyLong_Check(o)) {
    return __Complex(PyLong_AsLongLong(o), 0);
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

  %typemap(directorin) Complex {
    $input = PyComplex_FromDoubles($1_name.real(), $1_name.imag());
  }
  
  %typemap(directorin) const Complex & {
    $input = PyComplex_FromDoubles($1_name.real(), $1_name.imag());
  }
  
  %typemap(directorout) Complex {
    $result = SwigComplex_As< Complex >($input);
    if (PyErr_Occurred()) {
      throw Swig::DirectorTypeMismatchException("Expecting a complex or compatible type");
    }
  }  
  
  %typemap(directorout) const Complex & (Complex temp) {
    temp = SwigComplex_As< Complex >($input);
    if (PyErr_Occurred()) {
      throw Swig::DirectorTypeMismatchException("Expecting a complex or compatible type");
    }
    $result = &temp;
  }
  

%enddef  
     
namespace std
{
  template <class T> class complex;  
}

swig_specialize_complex(std::complex<float>);
swig_specialize_complex(std::complex<double>);
  
#endif // SWIG

#endif //SWIG_STD_COMPLEX_I_
