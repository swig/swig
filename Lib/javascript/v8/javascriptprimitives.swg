%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE 
v8::Handle<v8::Value> 
SWIG_From_dec(bool)(bool value)
{
  return v8::Boolean::New(value);
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
          fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN
int SWIG_AsVal_dec(bool)(v8::Handle<v8::Value> obj, bool *val)
{
  if(!obj->IsBoolean()) {
    return SWIG_ERROR;
  }
  
  if (val) *val = obj->BooleanValue();
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(int),"header") {
SWIGINTERNINLINE
v8::Handle<v8::Value> SWIG_From_dec(int)(int value)
{
  return v8::Int32::New(value);
}
}

%fragment(SWIG_AsVal_frag(int),"header") {
SWIGINTERN 
int SWIG_AsVal_dec(int)(v8::Handle<v8::Value> valRef, int* val)
{
  if (!valRef->IsNumber()) {
    return SWIG_TypeError;
  }
  if(val) *val = valRef->IntegerValue();
  
  return SWIG_OK;
}
}


%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE
v8::Handle<v8::Value> SWIG_From_dec(long)(long value)
{
  return v8::Number::New(value);
}
}

%fragment(SWIG_AsVal_frag(long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN 
int SWIG_AsVal_dec(long)(v8::Handle<v8::Value> obj, long* val)
{
  if (!obj->IsNumber()) {
    return SWIG_TypeError;
  }
  if(val) *val = (long) obj->IntegerValue();
  
  return SWIG_OK;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
          fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE 
v8::Handle<v8::Value> SWIG_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    v8::Integer::NewFromUnsigned(value) : v8::Integer::New(%numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header",
          fragment="SWIG_CanCastAsInteger") {
SWIGINTERN 
int SWIG_AsVal_dec(unsigned long)(v8::Handle<v8::Value> obj, unsigned long *val) 
{
  if(!obj->IsNumber()) {
    return SWIG_TypeError;
  }
  
  long longVal = (long) obj->NumberValue();
  
  if(longVal < 0) {
      return SWIG_OverflowError;
  }
  
  if(val) *val = longVal; 
  
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(double),"header") {
SWIGINTERN 
v8::Handle<v8::Value> SWIG_From_dec(double) (double val)
{
  return v8::Number::New(val);
}
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN 
int SWIG_AsVal_dec(double)(v8::Handle<v8::Value> obj, double *val)
{
  if(!obj->IsNumber()) {
    return SWIG_TypeError;
  }
  if(val) *val = obj->NumberValue();
  
  return SWIG_OK;
}
}

%typemap(in) char *
%{
    v8::String::Utf8Value _$1($input);
    $1 = *_$1;
%}

