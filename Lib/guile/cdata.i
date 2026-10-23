/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

%typemap(in) (const void *BYTES, size_t LENGTH) {
  size_t temp;
  $1 = ($1_ltype) scm_to_stringn($input, &temp,"latin1",SCM_FAILED_CONVERSION_ESCAPE_SEQUENCE);
  $2 = ($2_ltype) temp;
}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out) SWIGCDATA {
  $result = scm_from_stringn($1.data,$1.len,"latin1",SCM_FAILED_CONVERSION_ESCAPE_SEQUENCE);
}

%include <typemaps/cdata_end.swg>
