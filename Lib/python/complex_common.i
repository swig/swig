#ifndef __python_complex_common_i__
#define __python_complex_common_i__

/*
  Defines the As/From conversors for double/float complex, you need to
  provide complex Type, the Name you want to use in the conversors,
  the complex Constructor method, and the Real and Imag complex
  accesor methods.

  See the std_complex.i and ccomplex.i for concret examples.
*/

/* the common from conversor */
%define %swig_fromcplx_conv(Type, Name, Real, Imag)
%fragment("SWIG_From"#Name,"header")
%{
SWIGSTATIC(PyObject*)
SWIG_From##Name(Type c)
{
  return PyComplex_FromDoubles(Real(c), Imag(c));
}
%}
%enddef
  

/* the double case */
%define %swig_cplxdbl_conv(Type, Name, Constructor, Real, Imag)
%fragment("SWIG_As"#Name,"header",
          fragment="SWIG_AsDouble")
%{
SWIGSTATIC(Type)
SWIG_As##Name(PyObject *o)
{
  Type c = PyComplex_Check(o) ?
    Constructor(PyComplex_RealAsDouble(o),
		PyComplex_ImagAsDouble(o)) :
    Constructor(SWIG_AsDouble(o), 0);
  if (PyErr_Occurred()){
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a Type is expected");
  }
  return c;
}
%}
%swig_fromcplx_conv(Type, Name, Real, Imag);
%enddef

/* the float case */
%define %swig_cplxflt_conv(Type, Name, Constructor, Real, Imag)
%fragment("SWIG_As"#Name,"header",
	  fragment="SWIG_CheckFloat",
          fragment="SWIG_AsDouble")
%{
SWIGSTATIC(Type)
SWIG_As##Name(PyObject *o)
{
  Type c = PyComplex_Check(o) ?
    Constructor(SWIG_CheckFloat(PyComplex_RealAsDouble(o)),
		SWIG_CheckFloat(PyComplex_RealAsDouble(o))) :
    Constructor(SWIG_CheckFloat(SWIG_AsDouble(o)),0);
  if (PyErr_Occurred()) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a Type is expected");
  }
  return c;
 }
%}

%swig_fromcplx_conv(Type, Name, Real, Imag);
%enddef


#endif //__python_complex_common_i__
