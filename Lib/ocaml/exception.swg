/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment with any support code that it needs.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

/* Raise the error, mapping the SWIG error code to an OCaml exception */
%fragment("SWIG_exception", "header") %{
SWIGINTERN void SWIG_OCamlException(int code, const char *msg) {
  CAMLparam0();

  SWIG_OCamlExceptionCodes exception_code = SWIG_OCamlUnknownError;
  switch (code) {
  case SWIG_DivisionByZero:
    exception_code = SWIG_OCamlArithmeticException;
    break;
  case SWIG_IndexError:
    exception_code = SWIG_OCamlIndexOutOfBoundsException;
    break;
  case SWIG_IOError:
  case SWIG_SystemError:
    exception_code = SWIG_OCamlSystemException;
    break;
  case SWIG_MemoryError:
    exception_code = SWIG_OCamlOutOfMemoryError;
    break;
  case SWIG_OverflowError:
    exception_code = SWIG_OCamlOverflowException;
    break;
  case SWIG_RuntimeError:
    exception_code = SWIG_OCamlRuntimeException;
    break;
  case SWIG_SyntaxError:
  case SWIG_TypeError:
  case SWIG_ValueError:
    exception_code = SWIG_OCamlIllegalArgumentException;
    break;
  case SWIG_NullReferenceError:
    exception_code = SWIG_OCamlNullReferenceException;
    break;
  case SWIG_UnknownError:
  default:
    exception_code = SWIG_OCamlUnknownError;
    break;
  }
  SWIG_OCamlThrowException(exception_code, msg);
  CAMLreturn0;
}
#define SWIG_exception(code, msg) SWIG_OCamlException(code, msg)
%}
