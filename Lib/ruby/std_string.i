//
// std::string
//

#ifndef SWIG_STD_BASIC_STRING
#define SWIG_STD_STRING

%{
#include <string>
%}

namespace std
{
  class string;
}
  
%include <typemaps/std_string.swg>
%include <rubystrings.swg>

%std_string_asptr(std::string, char, SWIG_AsCharPtrAndSize)
%std_string_from(std::string,  SWIG_FromCharPtrAndSize)
%std_string_asval(std::string)

%typemap_asptrfromn(SWIG_CCode(STRING), std::string);

#else

%include <std/std_string.i>

#endif
