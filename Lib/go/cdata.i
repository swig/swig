/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

%fragment("cdata", "header") %{
struct swigcdata {
  intgo size;
  void *data;
};
%}

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

%typemap(gotype) (const void *BYTES, size_t LENGTH) "[]byte"
%typemap(in) (const void *BYTES, size_t LENGTH)
%{
  $1 = ($1_ltype)$input.array;
  $2 = ($2_ltype)$input.len;
%}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata.swg>

