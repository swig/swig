//
// SWIG typemaps for std::string
// Luigi Ballabio and Manu ???
// Apr 26, 2002
//
// Tcl implementation


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
        $1 = std::string(Tcl_GetStringFromObj($input,NULL));
    }

    %typemap(in) const string & (std::string temp) {
        temp = std::string(Tcl_GetStringFromObj($input,NULL));
        $1 = &temp;
    }

    %typemap(out) string {
        Tcl_SetStringObj($result,(char*)$1.c_str(),$1.length());
    }

    %typemap(out) const string & {
        Tcl_SetStringObj($result,(char*)$1->c_str(),$1->length());
    }

    %typemap(throws) string {
        Tcl_SetObjResult(interp, Tcl_NewStringObj((char*) $1.c_str(), -1));
        SWIG_fail;
    }

    %typemap(throws) const string & {
        Tcl_SetObjResult(interp, Tcl_NewStringObj((char*) $1.c_str(), -1));
        SWIG_fail;
    }
}
