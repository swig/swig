/*
  Defines the As/From converters for double/float complex, you need to
  provide complex Type, the Name you want to use in the converters,
  the complex Constructor method, and the Real and Imag complex
  accessor methods.

  See the std_complex.i and ccomplex.i for concrete examples.
*/

/* the common from converter */
%define %swig_fromcplx_conv(Type, Real, Imag)
%fragment(SWIG_From_frag(Type),"header",
          fragment=SWIG_From_frag(double))
{
SWIGINTERNINLINE Napi::Value
SWIG_From_dec(Type)(%ifcplusplus(const Type&, Type) c)
{
  Napi::Array vals = Napi::Array::New(0);

  vals.Set(0, SWIG_From(double)(Real(c)));
  vals.Set(1, SWIG_From(double)(Imag(c)));
  return vals;
}
}
%enddef

/* the double case */
%define %swig_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(SWIG_AsVal_frag(Type),"header",
	  fragment=SWIG_AsVal_frag(double))
{
SWIGINTERN int
SWIG_AsVal_dec(Type) (Napi::Value o, Type* val)
{
  if (o.IsArray()) {
    Napi::Array array = Napi::Array::Cast(o);
    
    if (array->Length() != 2) SWIG_Error(SWIG_TypeError, "Illegal argument for complex: must be array[2].");
    double re, im;
    Napi::Value r;

    r = array.Get(0);
    if (!r.IsNumber()) {
      return SWIG_TypeError;
    }
    re = r.ToNumber().DoubleValue();
    
    r = array.Get(1);
    if (!r.IsNumber()) {
      return SWIG_TypeError;
    }
    im = r.ToNumber().DoubleValue();
    
    if (val) *val = Constructor(re, im);
    return SWIG_OK;
  } else if (o.IsNumber()) {
    double d = o.ToNumber().DoubleValue();
    if (val) *val = Constructor(d, 0.0);
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}
%swig_fromcplx_conv(Type, Real, Imag);
%enddef

/* the float case */
%define %swig_cplxflt_conv(Type, Constructor, Real, Imag)
%fragment(SWIG_AsVal_frag(Type),"header",
          fragment=SWIG_AsVal_frag(float)) {
SWIGINTERN int
SWIG_AsVal_dec(Type) (Napi::Value o, Type* val)
{
  if (o.IsArray()) {
    Napi::Array array = o.As<Napi::Array>();
    
    if (array.Length() != 2) SWIG_Error(SWIG_TypeError, "Illegal argument for complex: must be array[2].");
    double re, im;
    Napi::Value r;
    
    r = array.Get(0);
    if (!r.IsNumber()) {
      return SWIG_TypeError;
    }
    re = r.ToNumber().DoubleValue();
    
    r = array.Get(1);
    if (!r.IsNumber()) {
      return SWIG_TypeError;
    }
    im = r.ToNumber().DoubleValue();
    
    if ((-FLT_MAX <= re && re <= FLT_MAX) && (-FLT_MAX <= im && im <= FLT_MAX)) {
      if (val) *val = Constructor(%numeric_cast(re, float),
                                  %numeric_cast(im, float));
      return SWIG_OK;
    } else {
      return SWIG_OverflowError;
    }    
  } else if (o.IsNumber()) {
    float f = static_cast<float>(o.ToNumber().DoubleValue());
    if (val) *val = Constructor(f, 0.0);
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}
%swig_fromcplx_conv(Type, Real, Imag);
%enddef

#define %swig_cplxflt_convn(Type, Constructor, Real, Imag) \
%swig_cplxflt_conv(Type, Constructor, Real, Imag)


#define %swig_cplxdbl_convn(Type, Constructor, Real, Imag) \
%swig_cplxdbl_conv(Type, Constructor, Real, Imag)
