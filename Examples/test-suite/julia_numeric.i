%module julia_numeric

#ifdef SWIGJULIA
%typemap(ctype) long long boxed "jl_value_t *"
%typemap(jltype) long long boxed "Any"
%typemap(jlparam) long long boxed "Any"
%typemap(in, fragment=SWIG_AsVal_frag(long long)) long long boxed %{
  if (!SWIG_IsOK(SWIG_AsVal_long_SS_long($input, &$1)))
    throw std::runtime_error("integer conversion failed");
%}

#endif

%inline %{
const int &int_result() { static const int value = -123; return value; }
const unsigned long long &unsigned_result() { static const unsigned long long value = ~0ULL; return value; }
const float &float_result() { static const float value = 1.25f; return value; }
const double &double_result() { static const double value = -2.5; return value; }
const bool &bool_result(bool value) { static bool result; result = value; return result; }
long long roundtrip(long long value) { return value; }
unsigned long long unsigned_roundtrip(unsigned long long value) { return value; }
long long boxed_roundtrip(long long boxed) { return boxed; }
int signed_byte(signed char value) { return value; }
unsigned int unsigned_byte(unsigned char value) { return value; }
bool bool_reference(const bool& value) { return value; }
long long integer_reference(const long long& value) { return value; }
%}
