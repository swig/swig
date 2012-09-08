%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE 
JSValueRef SWIG_From_dec(bool)(bool value)
{
  return JSValueMakeBoolean(context, value);
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
          fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN
int SWIG_AsVal_dec(bool)(JSValueRef obj, bool *val)
{
  if(!JSValueIsBoolean(context, obj)) {
    return SWIG_ERROR;
  }
  if (val) *val = JSValueToBoolean(context, obj);
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(int),"header") {
SWIGINTERNINLINE JSValueRef
  SWIG_From_dec(int)(int value)
{
  return JSValueMakeNumber(context, value);
}
}

%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE JSValueRef
  SWIG_From_dec(long)(long value)
{
  return JSValueMakeNumber(context, value);
}
}

%fragment(SWIG_AsVal_frag(long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(long)(JSValueRef obj, long* val)
{
  if (!JSValueIsNumber(context, obj)) {
    return SWIG_TypeError;
  }
  if(val) *val = (long) JSValueToNumber(context, obj, NULL);
  
  return SWIG_OK;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
          fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE JSValueRef 
SWIG_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    JSValueMakeNumber(context, value) : JSValueMakeNumber(context, %numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(JSValueRef obj, unsigned long *val) 
{
  if(!JSValueIsNumber(context, obj)) {
    return SWIG_TypeError;
  }
  
  long longVal = (long) JSValueToNumber(context, obj, NULL);
  
  if(longVal < 0) {
      return SWIG_OverflowError;
  }
  
  if(val) *val = longVal; 
  
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(double),"header") {
SWIGINTERN JSValueRef
SWIG_From_dec(double) (double val)
{
  return JSValueMakeNumber(context, val);
}
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(JSValueRef obj, double *val)
{
  if(!JSValueIsNumber(context, obj)) {
    return SWIG_TypeError;
  }
  if(val) *val = JSValueToNumber(context, obj, NULL);
  
  return SWIG_OK;
}
}
