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

%include <typemaps/cdata_begin.swg>

%typemap(dtype) SWIGCDATA "ubyte[]"
%typemap(imtype) SWIGCDATA "ubyte[]"
%typemap(ctype) SWIGCDATA "SWIG_c_array"
%typemap(out) SWIGCDATA %{
  $result.array = $1.data;
  $result.len = $1.len;
%}
%typemap(dout) SWIGCDATA { return $imcall; }

%include <typemaps/cdata_end.swg>
