/*
  Defines the As/From conversors for double/float complex, you need to
  provide complex Type, the Name you want to use in the conversors,
  the complex Constructor method, and the Real and Imag complex
  accesor methods.

  See the std_complex.i and ccomplex.i for concret examples.
*/

/* the common from conversor */
%define %swig_fromcplx_conv(Type, Real, Imag)
%fragment(SWIG_From_frag(Type),"header")
%{
SWIGINTERNINLINE PyObject*
  SWIG_From(Type)(SWIG_cplusplus(const Type&, Type) c)
{
  return PyComplex_FromDoubles(Real(c), Imag(c));
}
%}
%enddef

/* the double case */
%define %swig_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(SWIG_AsVal_frag(Type),"header",
	  fragment=SWIG_AsVal_frag(double))
%{
SWIGINTERN int
  SWIG_AsVal(Type) (PyObject *o, Type* val)
{
  if (PyComplex_Check(o)) {
    if (val) *val = Constructor(PyComplex_RealAsDouble(o),
				PyComplex_ImagAsDouble(o));
    return 1;
  } else {
    double d;    
    if (SWIG_AsVal(double)(o, &d)) {
      if (val) *val = Constructor(d, 0.0);
      return 1;
    } else {
      PyErr_Clear();
    }
  }  
  if (val) {
    SWIG_type_error("Type", o);
  }
  return 0;
}
%}
%swig_fromcplx_conv(Type, Real, Imag);
%enddef

/* the float case */
%define %swig_cplxflt_conv(Type, Constructor, Real, Imag)
%fragment(SWIG_AsVal_frag(Type),"header",
	  fragment="SWIG_CheckDoubleInRange",
          fragment=SWIG_AsVal_frag(float)) {
SWIGINTERN int
  SWIG_AsVal(Type)(PyObject *o, Type *val)
{
  const char* errmsg = val ? #Type : 0;
  if (PyComplex_Check(o)) {
    double re = PyComplex_RealAsDouble(o);
    double im = PyComplex_ImagAsDouble(o);
    if (SWIG_CheckDoubleInRange(re, -FLT_MAX, FLT_MAX, errmsg)
	&& SWIG_CheckDoubleInRange(im, -FLT_MAX, FLT_MAX, errmsg)) {
      if (val) *val = Constructor(SWIG_numeric_cast(re, float),
				  SWIG_numeric_cast(im, float));
      return 1;
    } else {
      return 0;
    }    
  } else {
    double re;    
    if (SWIG_AsVal(double)(o, &re)) {
      if (SWIG_CheckDoubleInRange(re, -FLT_MAX, FLT_MAX, errmsg)) {
	if (val) *val = Constructor(SWIG_numeric_cast(re,float), 0.0);      
	return 1;
      } else {
	return 0;
      }
    } else {
      PyErr_Clear();
    }
  }
  if (val) {
    SWIG_type_error("Type", o);
  }
  return 0;
}
}

%swig_fromcplx_conv(Type, Real, Imag);
%enddef

#define %swig_cplxflt_convn(Type, Constructor, Real, Imag) \
%swig_cplxflt_conv(Type, Constructor, Real, Imag)


#define %swig_cplxdbl_convn(Type, Constructor, Real, Imag) \
%swig_cplxdbl_conv(Type, Constructor, Real, Imag)


