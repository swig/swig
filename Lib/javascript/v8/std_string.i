/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&.
 *
 * To use non-const std::string references use the following %apply:
 *      %apply const std::string & {std::string &};
 *
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

%fragment("SWIGV8_valueToString", "header", fragment="SWIG_AsCharPtrAndSize") {
std::string* SWIGV8_valueToStringPtr(v8::Handle<v8::Value> val) {
  int alloc;
  size_t size;
  char* chars;
  int res = SWIG_AsCharPtrAndSize(val, &chars, &size, &alloc);
  
  if(res != SWIG_OK) {
    v8::ThrowException(v8::Exception::TypeError(v8::String::New("Could not convert to string.")));
    return 0;
  }
  
  // copies the data (again)
  std::string *str = new std::string(chars);
  
  if (alloc) delete[] chars;

  return str;
}
}

%fragment("SWIGV8_stringToValue", "header", fragment="SWIG_FromCharPtrAndSize") {
v8::Handle<v8::Value> SWIGV8_stringToValue(const std::string &str) {
  return SWIG_FromCharPtrAndSize(str.c_str(), str.length());
}
}

namespace std {
  %naturalvar string;

  class string;

  %typemap(in, fragment="SWIGV8_valueToString") string (std::string* tmp)
  %{ 
     tmp = SWIGV8_valueToStringPtr($input);
     $1 = *tmp;
     delete tmp;
  %}

  %typemap(in, fragment="SWIGV8_valueToString") const string & 
  %{ 
     $1 = SWIGV8_valueToStringPtr($input);
  %}
  
  %typemap(freearg) const string & 
  %{ 
     delete $1;
  %}

  %typemap(out, fragment="SWIGV8_stringToValue") string
  %{
     $result = SWIGV8_stringToValue($1);
  %}

  %typemap(out, fragment="SWIGV8_stringToValue") const string &
  %{
     $result = SWIGV8_stringToValue($1);
  %}

}
