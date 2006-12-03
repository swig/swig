/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_common.i
 *
 * SWIG typemaps for STL - common utilities
 * ----------------------------------------------------------------------------- */

%include <std/std_except.i>

%apply size_t { std::size_t };

%{
#include <string>

#define SWIG_FLOAT_P(x) ((TYPE(x) == T_FLOAT) || FIXNUM_P(x))

bool SWIG_BOOL_P(VALUE) {
    // dummy test, RTEST should take care of everything
    return true;
}
bool SWIG_RB2BOOL(VALUE x) {
    return RTEST(x);
}
VALUE SWIG_BOOL2RB(bool b) {
    return b ? Qtrue : Qfalse;
}
double SWIG_NUM2DBL(VALUE x) {
    return (FIXNUM_P(x) ? FIX2INT(x) : NUM2DBL(x));
}
bool SWIG_STRING_P(VALUE x) {
    return TYPE(x) == T_STRING;
}
std::string SWIG_RB2STR(VALUE x) {
    return std::string(RSTRING_PTR(x), RSTRING_LEN(x));
}
VALUE SWIG_STR2RB(const std::string& s) {
    return rb_str_new(s.data(), s.size());
}
%}
