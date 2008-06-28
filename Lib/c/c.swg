/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.swg
 * ----------------------------------------------------------------------------- */ 

%typemap(ctype) short       "short"
%typemap(ctype) int         "int"
%typemap(ctype) long        "long"
%typemap(ctype) char        "char"
%typemap(ctype) float       "float"
%typemap(ctype) double      "double"
%typemap(ctype) bool        "_Bool"
%typemap(ctype) SWIGTYPE    "struct $*1_typeObj *"

%typemap(in) short, int, long, char, float, double, bool "$1 = $input;"

%typemap(in) SWIGTYPE {
  $1 = ($1_type) $input->obj;
}

