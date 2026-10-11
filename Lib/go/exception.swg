/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment with any support code that it needs.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

/* Raise the error, which panics. In the runtime section, where go.cxx looks for _swig_gopanic. */
%fragment("SWIG_exception", "runtime") %{
#define SWIG_exception(code, msg) _swig_gopanic(msg)
%}
