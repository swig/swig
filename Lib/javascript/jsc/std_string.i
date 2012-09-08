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
%}

namespace std {

%naturalvar string;

class string;

// string
	
%typemap(in) string 
%{ if (!$input) {
	// TODO: Throw exception?
    return NULL;
   }
   JSStringRef $1_str = JSValueToStringCopy(context, $input, NULL);
   size_t $1_strsize = JSStringGetMaximumUTF8CStringSize($1_str);
   char* $1_cstr = (char *)malloc($1_strsize * sizeof(char));
   JSStringGetUTF8CString($1_str, $1_cstr, $1_strsize);
   $1 = std::string($1_cstr);
%}

%typemap(out) string %{
   JSStringRef	jsstring = JSStringCreateWithUTF8CString($1.c_str());
   $result = JSValueMakeString(context, jsstring);
   JSStringRelease(jsstring);
%}

%typemap(freearg) string	//TODO: Not working: A memory leak
%{ free($1_cstr); %}
	
//%typemap(typecheck) string = char *;

// const string &
%typemap(in) const string &
%{ if (!$input) {
	// TODO: Throw exception?
    return NULL;
   }
   JSStringRef $1_str = JSValueToStringCopy(context, $input, NULL);
   size_t $1_strsize = JSStringGetMaximumUTF8CStringSize($1_str);
   char* $1_cstr = (char *)malloc($1_strsize * sizeof(char));
   JSStringGetUTF8CString($1_str, $1_cstr, $1_strsize);
   $1 = new std::string($1_cstr);
%}
	
%typemap(out) const string & %{   
   JSStringRef	jsstring = JSStringCreateWithUTF8CString($1.c_str());
   $result = JSValueMakeString(context, jsstring);
   JSStringRelease(jsstring);
%}

%typemap(freearg) const string &  //TODO: Not working: A memory leak
%{ free($1_cstr); %}

//%typemap(typecheck) const string & = char *;

}
