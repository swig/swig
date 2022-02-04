/* -------------------------------------------------------------------------
 * std_except.i
 * -------------------------------------------------------------------------

%include <std_except.i>

%exception {
  // Make sure no unhandled exceptions exist before performing a new action
  SWIG_check_unhandled_exception();
  try {
    // Attempt the wrapped function call
    $action
  } catch (std::exception& e) {
    SWIG_exception(SWIG_RuntimeError, e.what() );
  } catch (...) {
    SWIG_exception(SWIG_UnknownError, "An unknown exception occurred");
  }
}

 * \endcode

 */
/* ------------------------------------------------------------------------- */

#ifndef __cplusplus
#error "This file can only be used when building C++"
#endif

%fragment("<stdexcept>");

%include <exception.i>

/* -------------------------------------------------------------------------
 * Exception mapping
 * ------------------------------------------------------------------------- */
%define %std_exception_map(EXCEPTION, CODE)
%typemap(throws, noblock=1) EXCEPTION {
  SWIG_exception(CODE, $1.what());
}
%ignore EXCEPTION;
struct EXCEPTION {};
%enddef

namespace std {
  %std_exception_map(bad_cast        , SWIG_TypeError);
  %std_exception_map(bad_exception   , SWIG_SystemError);
  %std_exception_map(domain_error    , SWIG_ValueError);
  %std_exception_map(exception       , SWIG_SystemError);
  %std_exception_map(invalid_argument, SWIG_ValueError);
  %std_exception_map(length_error    , SWIG_IndexError);
  %std_exception_map(logic_error     , SWIG_RuntimeError);
  %std_exception_map(out_of_range    , SWIG_IndexError);
  %std_exception_map(overflow_error  , SWIG_OverflowError);
  %std_exception_map(range_error     , SWIG_OverflowError);
  %std_exception_map(runtime_error   , SWIG_RuntimeError);
  %std_exception_map(underflow_error , SWIG_OverflowError);
}

