//
// SWIG typemaps for std::string
// Luigi Ballabio
// Apr 8, 2002
//
// Python implementation

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
        if (PyString_Check($input))
            $1 = std::string(PyString_AsString($input));
        else
            SWIG_exception(SWIG_TypeError, "string expected");
    }

    %typemap(in) const string & (std::string temp) {
        if (PyString_Check($input)) {
            temp = std::string(PyString_AsString($input));
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = PyString_FromString($1.c_str());
    }

    %typemap(out) const string & {
        $result = PyString_FromString($1->c_str());
    }
}

