// -*- C++ -*-
// SWIG typemaps for std::string
// Art Yerkes
// Modified from: Luigi Ballabio
// Apr 8, 2002
//
// Ocaml implementation

// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------

%include exception.i

%{
#include <string>
%}

namespace std {

    class string;

    /* Overloading check */

    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string {
        if (caml_ptr_check($input))
            $1 = std::string((char *)caml_ptr_val($input,0));
        else
            SWIG_exception(SWIG_TypeError, "string expected");
    }

    %typemap(in) const string & (std::string temp) {
        if (caml_ptr_check($input)) {
            temp = std::string((char *)caml_ptr_val($input,0));
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = caml_val_ptr((char *)$1.c_str(),0);
    }

    %typemap(out) const string & {
        $result = caml_val_ptr((char *)$1->c_str(),0);
    }
}

