// -*- C++ -*- 
// SWIG typemaps for STL - common utilities
// Art Yerkes
// Modified from: Luigi Ballabio
// Aug 3, 2002
//
// Ocaml implementation

%include <std/std_except.i>

%apply size_t { std::size_t };

%{
#include <string>
    CAML_VALUE SwigString_FromString(const std::string& s) {
	return caml_val_string((char *)s.c_str());
    }
    std::string SwigString_AsString(CAML_VALUE o) {
	return std::string((char *)caml_ptr_val(o,0));
    }
%}
