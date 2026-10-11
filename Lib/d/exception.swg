/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment with any support code that it needs.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

/* Map a SWIG error code to a D exception */
%fragment("SWIG_DThrowException", "header") %{
SWIGINTERN void SWIG_DThrowException(int code, const char *msg) {
  SWIG_DExceptionCodes exception_code;
  switch(code) {
  case SWIG_IndexError:
    exception_code = SWIG_DNoSuchElementException;
    break;
  case SWIG_IOError:
    exception_code = SWIG_DIOException;
    break;
  case SWIG_ValueError:
    exception_code = SWIG_DIllegalArgumentException;
    break;
  case SWIG_NullReferenceError:
    exception_code = SWIG_DNullReferenceException;
    break;
  case SWIG_DivisionByZero:
  case SWIG_MemoryError:
  case SWIG_OverflowError:
  case SWIG_RuntimeError:
  case SWIG_TypeError:
  case SWIG_SyntaxError:
  case SWIG_SystemError:
  case SWIG_UnknownError:
  default:
    exception_code = SWIG_DException;
    break;
  }
  SWIG_DSetPendingException(exception_code, msg);
}
%}

// Raise the error for a SWIG error code and leave the wrapper
#define SWIG_exception(code, msg) { SWIG_DThrowException(code, msg); return $null; }
%fragment("SWIG_exception", "header", fragment="SWIG_DThrowException") {}
