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
            $1 = std::string(PyString_AsString($input),
                             PyString_Size($input));
        else
            SWIG_exception(SWIG_TypeError, "string expected");
    }

    %typemap(in) const string & (std::string temp) {
        if (PyString_Check($input)) {
            temp = std::string(PyString_AsString($input),
                               PyString_Size($input));
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = PyString_FromStringAndSize($1.data(),$1.size());
    }

    %typemap(out) const string & {
        $result = PyString_FromStringAndSize($1->data(),$1->size());
    }
    
    %typemap(inv, parse="s") string, const string &, string & "$1_name.c_str()";

    %typemap(inv, parse="s") string *, const string * "$1_name->c_str()";
    
    %typemap(outv) string {
        if (PyString_Check($input))
            $result = std::string(PyString_AsString($input),
                                  PyString_Size($input));
        else
            throw SWIG_DIRECTOR_TYPE_MISMATCH("string expected");
    }
    
    %typemap(outv) const string & (std::string temp) {
        if (PyString_Check($input)) {
            temp = std::string(PyString_AsString($input),
                               PyString_Size($input));
            $result = &temp;
        } else {
            throw SWIG_DIRECTOR_TYPE_MISMATCH("string expected");
        }
    }

}

