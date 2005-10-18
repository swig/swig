//
// std::wstring
//

#ifndef SWIG_STD_BASIC_STRING
#define SWIG_STD_WSTRING

%{
#include <string>
%}
  
namespace std
{
  class wstring;
}

%include <typemaps/std_string.i>
%include <tclwstrings.swg>

%fragment("Tcl_std_wstring_asptr","header",fragment="SWIG_AsCharPtrAndSize") {
%tcl_asptr_decl(std::wstring)
}
%fragment("Tcl_std_wstring_asval","header",fragment="Tcl_std_wstring_asptr") {
%tcl_asptr_decl(std::wstring)
}

%std_string_asptr_frag(std::wstring, wchar_t, SWIG_AsCharPtrAndSize, "Tcl_std_wstring_asptr")
%std_string_asval_frag(std::wstring, "Tcl_std_wstring_asval")
%std_string_from(std::wstring, SWIG_FromCharPtrAndSize)

%typemap_asptrfromn(SWIG_CCode(UNISTRING), std::wstring);

#else

%include <std/std_string.i>

#endif
