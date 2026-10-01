/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * SWIG typemaps for std::string
 * ----------------------------------------------------------------------------- */

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

    %naturalvar string;

    class string;

    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string {
        if (scm_is_string($input)) {
            size_t len;
            char *tempptr = scm_to_utf8_stringn($input, &len);
            $1.assign(tempptr, len);
            SWIG_free(tempptr);
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(in) const string & ($*1_ltype temp) {
        if (scm_is_string($input)) {
            size_t len;
            char *tempptr = scm_to_utf8_stringn($input, &len);
            temp.assign(tempptr, len);
            SWIG_free(tempptr);
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(in) string * {
        if (scm_is_string($input)) {
            size_t len;
            char *tempptr = scm_to_utf8_stringn($input, &len);
            $1 = new $*1_ltype(tempptr, len);
            SWIG_free(tempptr);
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = scm_from_utf8_stringn($1.data(), $1.size());
    }

    %typemap(out) const string & {
        $result = scm_from_utf8_stringn($1->data(), $1->size());
    }

    %typemap(out) string * {
        $result = scm_from_utf8_stringn($1->data(), $1->size());
    }

    %typemap(varin) string {
        if (scm_is_string($input)) {
            size_t len;
            char *tempptr = scm_to_utf8_stringn($input, &len);
            $1.assign(tempptr, len);
            SWIG_free(tempptr);
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(varout) string {
        $result = scm_from_utf8_stringn($1.data(), $1.size());
    }

    %typemap(throws) string {
      scm_throw(scm_from_locale_symbol("swig-exception"),
                scm_list_n(scm_from_utf8_stringn($1.data(), $1.size()), SCM_UNDEFINED));
    }

    %typemap(throws) const string & {
      scm_throw(scm_from_locale_symbol("swig-exception"),
                scm_list_n(scm_from_utf8_stringn($1.data(), $1.size()), SCM_UNDEFINED));
    }
}
