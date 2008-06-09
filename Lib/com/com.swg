/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * com.swg
 *
 * COM typemaps
 * ----------------------------------------------------------------------------- */

%typemap(ctype) void "void"
%typemap(ctype) int, const int & "/* ctype */ int"
%typemap(ctype) double, const double & "/*ctype */ double"
%typemap(ctype) long, const long & "/* ctype */ long"
%typemap(ctype) SWIGTYPE * "/* ctype */ void *"

%typemap(comtype) void "void"
%typemap(comtype) int, const int & "/* comtype */ int"
%typemap(comtype) double, const double & "/* comtype */ double"
%typemap(comtype) long, const long & "/* comtype */ long"
%typemap(comtype) SWIGTYPE * "/* comtype */ $comclassname *"

%typemap(in) int, double, long, SWIGTYPE * %{ /* in */ $1 = ($1_ltype)$input; %}

%typemap(out) int, double, long, SWIGTYPE * %{ /* out */ $result = $1; %}
%typemap(out) void ""
