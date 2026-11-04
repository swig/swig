/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

%include <typemaps/cdata_begin.swg>

%insert("cheader") {
typedef struct SWIGCDATA {
    char *data;
    size_t len;
} SWIGCDATA;
}

%typemap(ctype) SWIGCDATA "SWIGCDATA"
%typemap(cppouttype) SWIGCDATA "SWIGCDATA"

%typemap(out) SWIGCDATA {
    $result = $1;
}

%typemap(ctype) (const void* BYTES, size_t LENGTH) "const SWIGCDATA*"
%typemap(in) (const void* BYTES, size_t LENGTH) {
    $1 = $input->data;
    $2 = $input->len;
}

/* There are no (void *BYTES, size_t LENGTH) typemaps, so apply only the const ones instead of all those in cdata_end.swg */
%apply (const void *BYTES, size_t LENGTH) { (const void *BYTES, int LENGTH) }
%apply (const void *BYTES, size_t LENGTH) { (const void *indata, size_t inlen) }
#define SWIG_CDATA_APPLIED

%include <typemaps/cdata_end.swg>
