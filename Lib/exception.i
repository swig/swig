/* -----------------------------------------------------------------------------
 * exception.i
 *
 * SWIG library file providing language independent exception handling
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
/* For SWIG_CATCH_STDEXCEPT and SWIG_CATCH_UNKNOWN from swigexceptions.swg */
%fragment("<typeinfo>");
%fragment("<stdexcept>");

/* rethrow the unknown exception */

%typemap(throws,noblock=1, canthrow=1) (...) {
  SWIG_exception(SWIG_RuntimeError,"unknown exception");
}

#endif /* __cplusplus */

/* exception.i ends here */
