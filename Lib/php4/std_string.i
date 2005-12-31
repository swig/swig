//
// SWIG typemaps for std::string types
// Luigi Ballabio
// May 7, 2002
//
// PHP implementation


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

    %typemap(in) string {
        convert_to_string_ex($input);
        $1 = std::string(Z_STRVAL_PP($input),Z_STRLEN_PP($input));
    }

    %typemap(in) const string & (std::string temp) {
        convert_to_string_ex($input);
        temp = std::string(Z_STRVAL_PP($input),Z_STRLEN_PP($input));
        $1 = &temp;
    }

    %typemap(out) string {
        ZVAL_STRINGL($result,const_cast<char*>($1.data()),$1.length(),1);
    }

    %typemap(out) const string & {
        ZVAL_STRINGL($result,const_cast<char*>($1->data()),$1->length(),1);
    }

    %typemap(throws) string %{
      SWIG_PHP_Error(E_ERROR, (char *)$1.c_str());
    %}

    %typemap(throws) const string& %{
      SWIG_PHP_Error(E_ERROR, (char *)$1.c_str());
    %}
}
