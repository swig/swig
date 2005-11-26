//
// SWIG typemaps for std::string types
// Luigi Ballabio
// Apr 8, 2002
//
// MzScheme implementation

// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------

%include <exception.i>

%{
#include <string>
%}

namespace std {

    class string;

    /* Overloading check */

    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string {
        if (SCHEME_STRINGP($input))
            $1 = std::string(SCHEME_STR_VAL($input));
        else
            SWIG_exception(SWIG_TypeError, "string expected");
    }

    %typemap(in) const string & (std::string temp) {
        if (SCHEME_STRINGP($input)) {
            temp = std::string(SCHEME_STR_VAL($input));
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = scheme_make_string($1.c_str());
    }

    %typemap(out) const string & {
        $result = scheme_make_string($1->c_str());
    }

}


