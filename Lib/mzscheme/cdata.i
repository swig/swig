/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 *
 * TODO:
 *  Use generic cdata by deleting this file and implementing
 *   SWIG_AsCharPtrAndSize() and SWIG_FromCharPtrAndSize()
 *  Or implement (void *BYTES, size_t LENGTH) and SWIGCDATA typemaps
 * ----------------------------------------------------------------------------- */

%typemap(in) (const void *BYTES, size_t LENGTH) {}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out) SWIGCDATA ""

%include <typemaps/cdata_end.swg>
