/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to a JSCore String and are passed around by value.
 *
 * To use non-const std::string references use the following %apply.  Note 
 * that they are passed by value.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>

std::string SWIGJSC_valueToString(JSContextRef context, JSValueRef value) {
  JSStringRef jsstring = JSValueToStringCopy(context, value, /* JSValueRef *exception */ 0);
  unsigned int length = JSStringGetLength(jsstring);
  char *cstr = new char[length+1];
  JSStringGetUTF8CString(jsstring, cstr, length);

  // create a copy
  std::string result(cstr);

  JSStringRelease(jsstring);
  delete[] cstr;

  return result;
}

JSValueRef SWIGJSC_stringToValue(JSContextRef context, const std::string& s)
{
  JSValueRef result;
  JSStringRef	jsstring = JSStringCreateWithUTF8CString(s.c_str());
  result = JSValueMakeString(context, jsstring);
  JSStringRelease(jsstring);
  return result;
}
%}

namespace std {

%naturalvar string;

class string;

// string
	
%typemap(in) string, const string& 
%{ 
   $1 = SWIGJSC_valueToString(context, $input);
%}

%typemap(out) string, const string&
%{
   $result = SWIGJSC_stringToValue(context, $1);
%}

}
