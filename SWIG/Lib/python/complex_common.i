#ifndef __python_complex_common_i__
#define __python_complex_common_i__

%define %swig_fromcplx_conv(Type, Name, Real, Imag)
%fragment("SWIG_PyObj_From"#Name,"header")
%{
SWIGSTATIC(PyObject*)
SWIG_PyObj_From##Name(Type c)
{
  return PyComplex_FromDoubles(Real(c), Imag(c));
}
%}
%enddef

%define %swig_cplxdbl_conv(Type, Name, Constructor, Real, Imag)
%fragment("SWIG_PyObj_As"#Name,"header",fragment="SWIG_PyObj_AsDouble")
%{
SWIGSTATIC(Type)
SWIG_PyObj_As##Name(PyObject *o)
{
  Type c = PyComplex_Check(o) ?
    Constructor(PyComplex_RealAsDouble(o),
		PyComplex_ImagAsDouble(o)) :
    Constructor(SWIG_PyObj_AsDouble(o), 0);
  if (PyErr_Occurred()){
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a Type is expected");
  }
  return c;
}
%}
%swig_fromcplx_conv(Type, Name, Real, Imag);
%enddef

%define %swig_cplxflt_conv(Type, Name, Constructor, Real, Imag)
%fragment("SWIG_PyObj_As"#Name,"header",fragment="SWIG_PyObj_AsDouble")
%{
SWIGSTATIC(Type)
SWIG_PyObj_As##Name(PyObject *o)
{
  Type c = PyComplex_Check(o) ?
    Constructor(SWIG_PyObj_AsFloatConv(o, PyComplex_RealAsDouble),
		SWIG_PyObj_AsFloatConv(o, PyComplex_ImagAsDouble)) :
    Constructor(SWIG_PyObj_AsFloatConv(o, SWIG_PyObj_AsDouble),
		0);
  if (PyErr_Occurred()){
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a Type is expected");
  }
  return c;
 }
%}
%swig_fromcplx_conv(Type, Name, Real, Imag);
%enddef


#endif //__python_complex_common_i__
