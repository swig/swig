// -*- C++ -*- 
// SWIG typemaps for STL - common utilities
// Art Yerkes
// Modified from: Luigi Ballabio
// Aug 3, 2002
//
// Ocaml implementation

%{
#include <string>
    value SwigString_FromString(const std::string& s) {
	return caml_val_string((char *)s.c_str());
    }
    std::string SwigString_AsString(value o) {
	return std::string((char *)caml_ptr_val(o,0));
    }
%}
