//
// SWIG typemaps for STL - common utilities
// Luigi Ballabio
// Aug 3, 2002
//
// MzScheme implementation

%{
#include <string>

std::string swig_scm_to_string(Scheme_Object* x) {
    return std::string(SCHEME_STR_VAL(x));
}
Scheme_Object* swig_make_string(const std::string& s) {
    return scheme_make_string(s.c_str());
}
%}
