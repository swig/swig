//
// std::wstring
//

#ifndef SWIG_STD_BASIC_STRING
#define SWIG_STD_WSTRING

%{
#include <cwchar>
#include <string>
%}

namespace std
{
  class wstring;
}
  
%include <typemaps/std_string.swg>
%include <pywstrings.swg>

%std_string_asptr(std::wstring, wchar_t, SWIG_AsWCharPtrAndSize)
%std_string_from(std::wstring,  SWIG_FromWCharPtrAndSize)
%std_string_asval(std::wstring)

%typemap_asptrfromn(SWIG_CCode(UNISTRING), std::wstring);

#else

%include <std/std_wstring.i>

#endif
