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
SWIG_From_dec(Type)(const Type& c)
{
  Napi::Array array = Napi::Array::New(env, 2);

  array.Set((uint32_t)0, SWIG_From(double)(Real(c)));
  array.Set((uint32_t)1, SWIG_From(double)(Imag(c)));
  return array;
}
}
%enddef

/* the double case */
%define %swig_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(SWIG_AsVal_frag(Type),"header", fragment=SWIG_AsVal_frag(double)) {
SWIGINTERN int
SWIG_AsVal_dec(Type) (Napi::Value o, Type* val)
{
  if (o.IsArray()) {
    Napi::Array array = o.As<Napi::Array>();

    if (array.Length() != 2)
      return SWIG_TypeError;

    Napi::Value r = array.Get((uint32_t)0);
    if (!r.IsNumber())
      return SWIG_TypeError;

    double re = r.ToNumber().DoubleValue();

    r = array.Get((uint32_t)1);
    if (!r.IsNumber())
      return SWIG_TypeError;

    double im = r.ToNumber().DoubleValue();

    if (val != NULL)
      *val = Constructor(re, im);
    return SWIG_OK;
  } else if (o.IsNumber()) {
    if (val != NULL)
      *val = Constructor(o.ToNumber().DoubleValue(), 0);
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}
%swig_fromcplx_conv(Type, Real, Imag);
%enddef

/* the float case */
%define %swig_cplxflt_conv(Type, Constructor, Real, Imag)
%fragment(SWIG_AsVal_frag(Type),"header", fragment=SWIG_AsVal_frag(float)) {
SWIGINTERN int
SWIG_AsVal_dec(Type) (Napi::Value o, Type* val)
{
  if (o.IsArray()) {
    Napi::Array array = o.As<Napi::Array>();

    if (array.Length() != 2)
      return SWIG_TypeError;

    Napi::Value r = array.Get((uint32_t)0);
    if (!r.IsNumber())
      return SWIG_TypeError;

    double re = r.ToNumber().DoubleValue();

    r = array.Get((uint32_t)1);
    if (!r.IsNumber())
      return SWIG_TypeError;

    double im = r.ToNumber().DoubleValue();

    if (-FLT_MAX > re || re > FLT_MAX || -FLT_MAX > im || im > FLT_MAX)
      return SWIG_OverflowError;

    if (val != NULL)
      *val = Constructor(%numeric_cast(re, float),
                         %numeric_cast(im, float));
    return SWIG_OK;
  } else if (o.IsNumber()) {
    double re = o.ToNumber().DoubleValue();
    if (-FLT_MAX > re || re > FLT_MAX)
      return SWIG_OverflowError;

    if (val != NULL)
      *val = Constructor(%numeric_cast(re, float), 0);
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
