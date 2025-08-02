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
  $1 = ($1_ltype) SWIG_Guile_scm2newstr($input, &temp);
  $2 = ($2_ltype) temp;
}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out) SWIGCDATA {
  $result = scm_from_locale_stringn($1.data,$1.len);
}

%include <typemaps/cdata_end.swg>
