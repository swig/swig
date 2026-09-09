/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

/* Store the message as the pending exception; swigCheckException() on the Swift side turns it into a thrown
 * NSError. The error code is not mapped to a Swift error type (the module surfaces every C++ exception as an
 * NSError), so it is intentionally unused. The pending exception functions are part of the runtime of every
 * module, so the fragment has nothing to add. */
#define SWIG_exception(code, msg) { (void)code; SWIG_Swift_SetPendingException(msg); return $null; }
%fragment("SWIG_exception", "header") {}
