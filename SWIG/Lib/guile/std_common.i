//
// SWIG typemaps for STL - common utilities
// Luigi Ballabio
// Aug 3, 2002
//
// Guile implementation

%{
#include <string>

SCM SWIG_bool2scm(bool b) {
    int i = b ? 1 : 0;
    return gh_bool2scm(i);
}
std::string SWIG_scm2string(SCM x) {
    char* temp;
    std::string s;
    temp = gh_scm2newstr(x, NULL);
    s = std::string(temp);
    if (temp) scm_must_free(temp);
    return s;
}
SCM SWIG_string2scm(const std::string& s) {
    return gh_str02scm(s.c_str());
}
%}
