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
%include <tclstrings.swg>

%fragment("Tcl_std_string_asptr","header",fragment="SWIG_AsCharPtrAndSize") {
%tcl_asptr_decl(std::string)
}
%fragment("Tcl_std_string_asval","header",fragment="Tcl_std_string_asptr") {
%tcl_asptr_decl(std::string)
}

%std_string_asptr_frag(std::string, char, SWIG_AsCharPtrAndSize, "Tcl_std_string_asptr")
%std_string_asval_frag(std::string, "Tcl_std_string_asval")
%std_string_from(std::string, SWIG_FromCharPtrAndSize)

%typemap_asptrfromn(SWIG_CCode(STRING), std::string);

#else

%include <std/std_string.i>

#endif
