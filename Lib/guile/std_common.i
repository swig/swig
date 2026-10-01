/* -----------------------------------------------------------------------------
 * std_common.i
 *
 * SWIG typemaps for STL - common utilities
 * ----------------------------------------------------------------------------- */

%include <std/std_except.i>

%apply size_t { std::size_t };

#define SWIG_bool2scm(b) scm_from_bool(b ? 1 : 0)

%{
#include <string>

SWIGINTERNINLINE
SCM SWIG_string2scm(const std::string& s) {
    return scm_from_utf8_stringn(s.data(), s.size());
}

SWIGINTERNINLINE
std::string SWIG_scm2string(SCM x) {
    size_t len;
    char* temp = SWIG_Guile_scm2newstr(x, &len);
    std::string s(temp, len);
    SWIG_free(temp);
    return s;
}
%}
