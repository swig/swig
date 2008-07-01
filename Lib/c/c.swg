/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.swg
 * ----------------------------------------------------------------------------- */ 

%typemap(ctype) void, short, int, long, char, float, double "$1_type"
%typemap(ctype) void*, short*, int*, long*, char*, float*, double* "$1_type"
%typemap(ctype) bool        "_Bool"
%typemap(ctype) SWIGTYPE    "struct $1_typeObj *"
%typemap(ctype) SWIGTYPE *  "struct $*1_typeObj *"
%typemap(ctype) SWIGTYPE &  "struct $*1_ltypeObj *"

%typemap(couttype) void, short, int, long, char, float, double "$1_type"
%typemap(couttype) void*, short*, int*, long*, char*, float*, double* "$1_type"
%typemap(couttype) bool       "_Bool"
%typemap(couttype) SWIGTYPE   "struct $1_typeObj"
%typemap(couttype) SWIGTYPE * "struct $*1_typeObj *"

%typemap(in) short, int, long, char, float, double, bool "$1 = $input;"
%typemap(in) void*, short*, int*, long*, char*, float*, double*, bool* "$1 = $input;"

%typemap(in) SWIGTYPE {
  $1 = * ($1_type *) ($input->obj);
}

%typemap(in) SWIGTYPE * {
  $1 = ($1_type) $input->obj;
}

%typemap(in) SWIGTYPE & {
  $1 = ($*1_ltype *) $input->obj;
}

%typemap(out) short, int, long, char, float, double, bool "$result = $1;"
%typemap(out) void*, short*, int*, long*, char*, float*, double*, bool* "$result = $1;"
%typemap(out) void ""

%typemap(out) SWIGTYPE {
  $result.obj = (void*) &$1;
}

%typemap(out) SWIGTYPE * {
  $result->obj = (void*) $1;
}

%typemap(out) SWIGTYPE & {
  // return by reference
}

