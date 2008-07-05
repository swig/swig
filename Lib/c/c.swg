/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.swg
 * ----------------------------------------------------------------------------- */ 

%insert("runtime") "clabels.swg"
%insert("shadow_header") "cproxy.swg"

// typemaps for function parameters

%typemap(ctype) void, short, int, long, char, float, double "$1_type"
%typemap(ctype) void*, short*, int*, long*, char*, float*, double* "$1_type"
%typemap(ctype) const short, const int, const long, const char, const float, const double "$1_basetype"
%typemap(ctype) bool                  "_Bool"
%typemap(ctype) SWIGTYPE              "$1_type"
%typemap(ctype) SWIGTYPE *            "$1_type"
%typemap(ctype) SWIGTYPE &            "$1_type"
%typemap(ctype) SWIGTYPE * [ANY]      "$1_basetype*"
%typemap(ctype) SWIGCLASSTYPE         "struct Obj$1_type"
%typemap(ctype) SWIGCLASSTYPE *       "struct Obj$1_type"
%typemap(ctype) SWIGCLASSTYPE &       "struct Obj$1_type"
%typemap(ctype) SWIGCLASSTYPE * [ANY] "struct Obj$1_basetype*"

%typemap(in) short, int, long, char, float, double, bool "$1 = ($1_basetype) $input;"
%typemap(in) void*, short*, int*, long*, char*, float*, double*, bool* "$1 = ($1_basetype*) $input;"
%typemap(in) SWIGTYPE                 "$1 = ($1_type) $input;"
%typemap(in) SWIGTYPE *               "$1 = ($1_type) $input;"
%typemap(in) SWIGTYPE &               "$1 = ($1_type) $input;"
%typemap(in) SWIGTYPE * [ANY]         "$1 = ($1_basetype*) $input;"
%typemap(in) SWIGCLASSTYPE {
  $1 = * ($1_type *) ($input.obj);
}

%typemap(in) SWIGCLASSTYPE * {
  $1 = ($1_type) $input->obj;
}

%typemap(in) SWIGCLASSTYPE * [ANY] {
  $1 = ($1_basetype*) malloc($1_dim0 * sizeof($1_basetype));
  int i;
  for (i = 0; i < $1_dim0; ++i)
    if ($input[i])
      $1[i] = ($1_basetype) $input[i]->obj;
    else
      $1[i] = ($1_basetype) 0;
}

%typemap(in) SWIGCLASSTYPE & {
  $1 = ($*1_ltype *) $input->obj;
}

// typemaps for return values

%typemap(couttype) void, short, int, long, char, float, double "$1_type"
%typemap(couttype) void*, short*, int*, long*, char*, float*, double* "$1_type"
%typemap(couttype) const short, const int, const long, const char, const float, const double "$1_basetype"
%typemap(couttype) bool       "_Bool"
%typemap(couttype) SWIGTYPE   "struct Obj$1_type"
%typemap(couttype) SWIGTYPE * "struct Obj$*1_type *"

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

