/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg), the SWIG_exception fragment with any support code that it needs and the throws typemaps for C++ exceptions.
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

/* Typemaps used for propagating C++ exceptions to D */

// Code which is inserted into the dout typemaps and class constructors via
// excode if exceptions can be thrown.
%define SWIGEXCODE "\n  if ($imdmodule.SwigPendingException.isPending) throw $imdmodule.SwigPendingException.retrieve();" %enddef

%typemap(throws, canthrow=1) int,
                 long,
                 short,
                 unsigned int,
                 unsigned long,
                 unsigned short
%{ char error_msg[256];
   SWIG_snprintf(error_msg, sizeof(error_msg), "C++ $1_type exception thrown, value: %d", $1);
   SWIG_DSetPendingException(SWIG_DException, error_msg);
   return $null; %}

%typemap(throws, canthrow=1) SWIGTYPE, SWIGTYPE &, SWIGTYPE *, SWIGTYPE [ANY],
  enum SWIGTYPE, const enum SWIGTYPE &
%{ (void)$1;
   SWIG_DSetPendingException(SWIG_DException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(throws, canthrow=1) char *
%{ SWIG_DSetPendingException(SWIG_DException, $1);
   return $null; %}
