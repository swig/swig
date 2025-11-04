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
SWIGINTERNINLINE JSValue
#if defined(__cplusplus)
SWIG_From_dec(Type)(const Type& c)
#else
SWIG_From_dec(Type)(Type c)
#endif
{
  JSValue r;
  r = JS_NewArray(ctx);
  if(!JS_IsException(r)) {
    JS_SetPropertyUint32(ctx, r, 0, SWIG_From(double)(Real(c)));
    JS_SetPropertyUint32(ctx, r, 1, SWIG_From(double)(Imag(c)));
  }
  return r;
}
}
%enddef

/* the double case */
%define %swig_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(SWIG_AsVal_frag(Type),"header",
	  fragment=SWIG_AsVal_frag(double))
{
SWIGINTERN int
SWIG_AsVal_dec(Type) (JSValue o, Type* val)
{
  if (JS_IsArray(ctx, o)) {
    JSValue js_re, js_im;
    double re, im;
    int res;
    
    res = 0;

    js_re = JS_GetPropertyUint32(ctx, o, 0);
    if(JS_IsException(js_re))
      return SWIG_TypeError;

    js_im = JS_GetPropertyUint32(ctx, o, 1);
    if(JS_IsException(js_im))
      return SWIG_TypeError;

    res = SWIG_AsVal(double)(js_re, &re);
    if(!SWIG_IsOK(res)) {
      return SWIG_TypeError;
    }
    
    res = SWIG_AsVal(double)(js_im, &im);
    if(!SWIG_IsOK(res)) {
      return SWIG_TypeError;
    }
    
    if (val) *val = Constructor(re, im);
    return SWIG_OK;
  } else {
    double d;
    int res = SWIG_AddCast(SWIG_AsVal(double)(o, &d));
    if (SWIG_IsOK(res)) {
      if (val) *val = Constructor(d, 0.0);
      return res;
    }
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
SWIG_AsVal_dec(Type)(JSValue o, Type *val)
{
  if (JS_IsArray(ctx, o)) {
    JSValue js_re, js_im;
    double re, im;
    int res;
    
    res = 0;

    js_re = JS_GetPropertyUint32(ctx, o, 0);
    if(JS_IsException(js_re)) 
      return SWIG_TypeError;

    js_im = JS_GetPropertyUint32(ctx, o, 1);
    if(JS_IsException(js_im))
      return SWIG_TypeError;

    res = SWIG_AsVal(double)(js_re, &re);
    if(!SWIG_IsOK(res)) {
      return SWIG_TypeError;
    }
    
    res = SWIG_AsVal(double)(js_im, &im);
    if(!SWIG_IsOK(res)) {
      return SWIG_TypeError;
    }

    if ((-FLT_MAX <= re && re <= FLT_MAX) && (-FLT_MAX <= im && im <= FLT_MAX)) {
      if (val) *val = Constructor(%numeric_cast(re, float),
                                  %numeric_cast(im, float));
      return SWIG_OK;
    } else {
      return SWIG_OverflowError;
    }    
  } else {
    float re;
    int res = SWIG_AddCast(SWIG_AsVal(float)(o, &re));
    if (SWIG_IsOK(res)) {
      if (val) *val = Constructor(re, 0.0f);
      return res;
    }
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
