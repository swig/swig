/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment with any support code that it needs.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

/* Raise the error with a message starting with the error code name, then leave the wrapper */
%fragment("SWIG_exception", "header") %{
SWIGINTERN const char *SWIG_Lua_ErrorType(int code) {
  switch (code) {
  case SWIG_MemoryError:        return "SWIG_MemoryError";
  case SWIG_IOError:            return "SWIG_IOError";
  case SWIG_RuntimeError:       return "SWIG_RuntimeError";
  case SWIG_IndexError:         return "SWIG_IndexError";
  case SWIG_TypeError:          return "SWIG_TypeError";
  case SWIG_DivisionByZero:     return "SWIG_DivisionByZero";
  case SWIG_OverflowError:      return "SWIG_OverflowError";
  case SWIG_SyntaxError:        return "SWIG_SyntaxError";
  case SWIG_ValueError:         return "SWIG_ValueError";
  case SWIG_SystemError:        return "SWIG_SystemError";
  case SWIG_AttributeError:     return "SWIG_AttributeError";
  case SWIG_NullReferenceError: return "SWIG_NullReferenceError";
  default:                      return "SWIG_UnknownError";
  }
}
#define SWIG_exception(code, msg) { lua_pushfstring(L, "%s:%s", SWIG_Lua_ErrorType(code), msg); SWIG_fail; }
%}
