//
// SWIG typemaps for std::string
// Roy M. LeCates
// October 23, 2002
//
// Perl implementation


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
        if (!SvPOK((SV*) $input)) {
            SWIG_croak("Type error in argument $argnum of $symname. "
                       "Expected a string");
        } else {
            STRLEN len;
            const char *ptr = SvPV($input, len);
            $1.assign(ptr, len);
        } 
    }

    %typemap(in) string *INPUT(std::string temp), 
                 const string & (std::string temp) {
        if (!SvPOK((SV*) $input)) {
            SWIG_croak("Type error in argument $argnum of $symname. "
                       "Expected a string");
        } else {
            STRLEN len;
            const char *ptr = SvPV($input, len);
            temp.assign(ptr, len);
            $1 = &temp;
        }
    }

    %typemap(out) string {
        if (argvi >= items) EXTEND(sp, 1);	// bump stack ptr, if needed
        char *data = const_cast<char*>($1.data());
        sv_setpvn($result = sv_newmortal(), data, $1.size());
        ++argvi;
    }

    %typemap(out) const string & {
        if (argvi >= items) EXTEND(sp, 1);	// bump stack ptr, if needed
        char *data = const_cast<char*>($1->data());
        sv_setpvn($result = sv_newmortal(), data, $1->size());
        ++argvi;
    }

}

