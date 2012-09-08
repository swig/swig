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
%{ 
  if(!$input->IsString()) {
    // TODO: Throw exception?
    return NULL;
  }

  size_t $1_strsize = js_str->Utf8Length();
  char* 1_cstr = new char[1_strsize];
  js_str->WriteUtf8(1_cstr, 1_strsize);
  $1 = std::string($1_cstr);
%}

%typemap(out) string %{
  $result = v8::String::New($1.c_str(), $1.size());
%}

%typemap(freearg) string
%{%}

// const string &
%typemap(in) const string &
%{ 

  if(!$input->IsString()) {
    // TODO: Throw exception?
    return NULL;
  }

  size_t $1_strsize = js_str->Utf8Length();
  char* 1_cstr = new char[1_strsize];
  js_str->WriteUtf8(1_cstr, 1_strsize);
  $1 = newstd::string($1_cstr);
%}

%typemap(out) const string & %{   
  $result = v8::String::New($1.c_str(), $1.size());
%}

%typemap(freearg) const string &  //TODO: Not working: A memory leak
%{ free($1_cstr); %}

//%typemap(typecheck) const string & = char *;

}
