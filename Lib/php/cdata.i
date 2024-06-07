/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

%typemap(in, phptype="string") (const void *BYTES, size_t LENGTH) %{
  convert_to_string(&$input);
  $1 = ($1_ltype) Z_STRVAL($input);
  $2 = ($2_ltype) Z_STRLEN($input);
%}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out) SWIGCDATA {
  ZVAL_STRINGL($result, $1.data, $1.len);
}

%include <typemaps/cdata_end.swg>
