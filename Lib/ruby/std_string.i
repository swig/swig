//
// SWIG typemaps for std::string
// Luigi Ballabio
// Apr 8, 2002
//
// Ruby implementation


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

    // Ruby wants class names to start with a capital letter
    %rename(String) string;
    class string;

    /* Overloading check */
    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string {
        if (TYPE($input) == T_STRING) {
            $1 = std::string(StringValuePtr($input));
        } else {
            SWIG_exception(SWIG_TypeError, "not a string");
        }
    }

    %typemap(in) const string & (std::string temp) {
        if (TYPE($input) == T_STRING) {
            temp = std::string(StringValuePtr($input));
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "not a string");
        }
    }

    %typemap(out) string {
        $result = rb_str_new2($1.c_str());
    }

    %typemap(out) const string & {
        $result = rb_str_new2($1->c_str());
    }

    %typemap(inv) string, const string &, string & "$1_name.c_str()";

    %typemap(inv) string *, const string * "$1_name->c_str()";
    
    %typemap(outv) string {
        if (TYPE($input) == T_STRING)
            $result = std::string(StringValuePtr($input));
        else
            throw SWIG_DIRECTOR_TYPE_MISMATCH("string expected");
    }
    
    %typemap(outv) const string & (std::string temp) {
        if (TYPE($input) == T_STRING) {
            temp = std::string(StringValuePtr($input));
            $result = &temp;
        } else {
            throw SWIG_DIRECTOR_TYPE_MISMATCH("string expected");
        }
    }

}
