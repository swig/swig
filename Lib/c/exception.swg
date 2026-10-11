/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment with any support code that it needs.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

#ifdef SWIG_C_EXCEPT
%include "cexcept.swg"
#else // !SWIG_C_EXCEPT
// Still define the macro used in some standard typemaps, but we can't
// implement it in C, so just allow the user predefining their own version.
%insert("runtime") %{
#ifndef SWIG_exception
#define SWIG_exception(code, msg)
#endif
%}

// Call any SWIG_exception defined in C above, which is not expanded again inside this macro, then leave the wrapper
#define SWIG_exception(code, msg) { SWIG_exception(code, msg); return $null; }
#endif // SWIG_C_EXCEPT/!SWIG_C_EXCEPT
%fragment("SWIG_exception", "header") {}
