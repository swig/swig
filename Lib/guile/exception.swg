/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment with any support code that it needs.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

/* Raise the error for a SWIG error code. NULL is a misc-error, as for the other null checks in the Guile typemaps. */
%fragment("SWIG_exception", "header") %{
SWIGINTERN void SWIG_Guile_Exception(int code, const char *msg, const char *subr) {
  const char *key;
  switch (code) {
  case SWIG_NullReferenceError:
    scm_misc_error(subr, "~A", scm_list_1(scm_from_locale_string(msg)));
    return;
  case SWIG_MemoryError:     key = "swig-memory-error"; break;
  case SWIG_IOError:         key = "swig-io-error"; break;
  case SWIG_RuntimeError:    key = "swig-runtime-error"; break;
  case SWIG_IndexError:      key = "swig-index-error"; break;
  case SWIG_TypeError:       key = "swig-type-error"; break;
  case SWIG_DivisionByZero:  key = "swig-division-by-zero"; break;
  case SWIG_OverflowError:   key = "swig-overflow-error"; break;
  case SWIG_SyntaxError:     key = "swig-syntax-error"; break;
  case SWIG_ValueError:      key = "swig-value-error"; break;
  case SWIG_SystemError:     key = "swig-system-error"; break;
  default:                   key = "swig-error"; break;
  }
  scm_error(scm_from_locale_symbol(key), subr, "~A", scm_list_1(scm_from_locale_string(msg)), SCM_BOOL_F);
}
#define SWIG_exception(code, msg) SWIG_Guile_Exception(code, msg, FUNC_NAME)
%}
