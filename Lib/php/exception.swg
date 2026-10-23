/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment with any support code that it needs.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

/* Raise the error for a SWIG error code and leave the wrapper */
%fragment("SWIG_exception", "header") %{
#define SWIG_exception(code, msg) do { zend_throw_exception( \
    code == SWIG_TypeError ? zend_ce_type_error : \
    code == SWIG_ValueError ? zend_ce_value_error : \
    code == SWIG_DivisionByZero ? zend_ce_division_by_zero_error : \
    code == SWIG_SyntaxError ? zend_ce_parse_error : \
    code == SWIG_OverflowError ? zend_ce_arithmetic_error : \
    code == SWIG_NullReferenceError ? zend_ce_type_error : \
    NULL, msg, code); SWIG_fail; } while (0)
%}
