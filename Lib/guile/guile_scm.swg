/* -----------------------------------------------------------------------------
 * guile_scm.swg
 *
 * This SWIG interface file is processed if the Guile module is run
 * with SCM_ flavor.
 * ----------------------------------------------------------------------------- */

#define SWIGGUILE_SCM

%runtime "swigrun.swg"       // Common C API type-checking code
%runtime "swigerrors.swg"    // SWIG errors

%runtime "guile_scm_run.swg"

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
%include <swigcommon.swg>
%include <guile.i>

%runtime %{

#define GUILE_MAYBE_VALUES \
      if (gswig_list_p) gswig_result = scm_values(gswig_result);

#define GUILE_MAYBE_VECTOR \
      if (gswig_list_p) gswig_result = scm_vector(gswig_result);

#define SWIG_APPEND_VALUE(object)						\
    if (gswig_result == SCM_UNSPECIFIED)						\
        gswig_result = object;							\
    else {									\
      if (!gswig_list_p) {							\
	      gswig_list_p = 1;							\
	      gswig_result = scm_list_n(gswig_result, object, SCM_UNDEFINED);	\
      }									\
      else									\
            gswig_result = scm_append(scm_list_n(gswig_result, scm_list_n(object, SCM_UNDEFINED), SCM_UNDEFINED));		\
    }

%}

%insert(init) "swiginit.swg"

%init %{
SWIG_GUILE_INIT_STATIC void
SWIG_init(void)
{
  SWIG_InitializeModule(0);
  SWIG_PropagateClientData();
%}
