%include <typemaps/valtypes.swg>

%fragment(SWIG_AsVal_frag(jstring),"header") {
SWIGINTERN int
SWIG_AsVal_dec(jstring)(SV *obj, jstring *val)
{
  return SWIG_ERROR;
}
}

%fragment(SWIG_From_frag(jstring),"header") {
SWIGINTERNINLINE SV *
SWIG_From_dec(jstring)(jstring val)
{

  SV *obj = sv_newmortal();
  return obj;
}
}

%typemaps_asvalfrom(%checkcode(STRING),
		    %arg(SWIG_AsVal(jstring)), 
		    %arg(SWIG_From(jstring)), 
		    %arg(SWIG_AsVal_frag(jstring)), 
		    %arg(SWIG_From_frag(jstring)), 
		    java::lang::String *);

