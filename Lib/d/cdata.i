/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */
%typemap(imtype)  (const void *BYTES, size_t LENGTH) "ubyte[]"
%typemap(dtype)   (const void *BYTES, size_t LENGTH) "ubyte[]"
%typemap(ctype)   (const void *BYTES, size_t LENGTH) "SWIG_c_array"
%typemap(din)     (const void *BYTES, size_t LENGTH) "$dinput"
%typemap(in, canthrow=1) (const void *BYTES, size_t LENGTH) %{
  $1 = ($1_ltype)$input.array;
  $2 = ($2_ltype)$input.len;
%}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata.swg>
