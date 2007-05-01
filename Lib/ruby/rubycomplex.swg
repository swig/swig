/*
  Defines the As/From conversors for double/float complex, you need to
  provide complex Type, the Name you want to use in the conversors,
  the complex Constructor method, and the Real and Imag complex
  accesor methods.

  See the std_complex.i and ccomplex.i for concret examples.
*/

/*
  Ruby does not have native complex numbers.  They are an extension in the
  STD library.
*/
%{
  static VALUE rb_cComplex = Qnil;
  static ID    real_id = Qnil;
  static ID    imag_id = Qnil;
%}

%init {
  rb_require("complex");
  rb_cComplex = rb_const_get( rb_cObject, rb_intern("Complex") );
  if ( rb_cComplex == Qnil )
    rb_warn("Complex numbers not available");
  real_id = rb_intern("real");
  imag_id = rb_intern("imag");
}

/* the common from conversor */
%define %swig_fromcplx_conv(Type, Real, Imag)
%fragment(SWIG_From_frag(Type),"header")
{
SWIGINTERNINLINE VALUE
SWIG_From(Type)(%ifcplusplus(const Type&, Type) c)
{
  VALUE args[] = { 
    rb_float_new(Real(c)), 
    rb_float_new(Imag(c))
  };
  return rb_class_new_instance(2, args, rb_cComplex);
}
}
%enddef

/* the double case */
%define %swig_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(SWIG_AsVal_frag(Type),"header",
	  fragment=SWIG_AsVal_frag(double))
{
SWIGINTERN int
SWIG_AsVal(Type) (VALUE o, Type* val)
{
  if ( rb_obj_is_kind_of( o, rb_cComplex) ) {
    if (val) {
      VALUE real = rb_funcall(o, real_id, 0 );
      VALUE imag = rb_funcall(o, imag_id, 0 );
      *val = Constructor(RFLOAT(real)->value, RFLOAT(imag)->value);
      return SWIG_OK;
    }
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
SWIG_AsVal(Type)(VALUE o, Type *val)
{
  if ( rb_obj_is_kind_of( o, rb_cComplex) ) {
    VALUE real = rb_funcall(o, real_id, 0 );
    VALUE imag = rb_funcall(o, imag_id, 0 );
    double re = RFLOAT(real)->value;
    double im = RFLOAT(imag)->value;
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
      if (val) *val = Constructor(re, 0.0);
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


