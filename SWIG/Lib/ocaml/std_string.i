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

%include exception.i

%{
#include <string>
%}

namespace std {

    class string;

    %typemap(in) string {
	$1 = String_val($input);
    }

    %typemap(in) const string & (std::string temp) {
	temp = std::string(String_val($input));
        $1 = &temp;
    }

    %typemap(out) string {
        $result = copy_string($1.c_str());
    }

    %typemap(out) const string & {
	$result = copy_string($1->c_str());
    }

}


