/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * com.swg
 *
 * COM typemaps
 * ----------------------------------------------------------------------------- */

%typemap(ctype) void "void"
%typemap(ctype) int, const int & "int"
%typemap(ctype) double, const double & "double"
%typemap(ctype) long, const long & "long"
%typemap(ctype) SWIGTYPE * "void *"

%typemap(comtype) void "void"
%typemap(comtype) int, const int & "int"
%typemap(comtype) double, const double & "double"
%typemap(comtype) long, const long & "long"
%typemap(comtype) SWIGTYPE * "$comclassname *"

%typemap(in) int "int"
%typemap(in) double "double"
%typemap(in) long "long"
%typemap(in) SWIGTYPE * %{ $1 = ($1_ltype)$input; %}

