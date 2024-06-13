/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 *
 * TODO: Need to test with li_cdata_cpp and li_cdata
 * ----------------------------------------------------------------------------- */

%typemap(in) (const void *BYTES, size_t LENGTH) {
  $1 = ($1_ltype) caml_string_val($input);
  $2 = ($2_ltype) caml_string_len($input);
}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out) SWIGCDATA %{ caml_val_string_len($1.data,$1.len); %}

%include <typemaps/cdata_end.swg>
