/* -----------------------------------------------------------------------------
 * cdata.swg
 *
 * apply raw C data typemaps.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

%apply (const void *BYTES, size_t LENGTH) { (const void *BYTES, int LENGTH) }
%apply (void *BYTES, size_t LENGTH) { (void *BYTES, int LENGTH) }
/* type map for memmove() function */
%apply (const void *BYTES, size_t LENGTH) { (const void *indata, size_t inlen) }
