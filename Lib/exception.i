//
// exception.i
// Dave Beazley
// April 14, 1997
//
// This SWIG library file provides language independent exception handling

%{
#define  SWIG_MemoryError    1
#define  SWIG_IOError        2
#define  SWIG_RuntimeError   3
#define  SWIG_IndexError     4
#define  SWIG_TypeError      5
#define  SWIG_DivisionByZero 6
#define  SWIG_OverflowError  7
#define  SWIG_SyntaxError    8
#define  SWIG_ValueError     9
#define  SWIG_SystemError   10
#define  SWIG_UnknownError  99
%}

#ifdef SWIGTCL8
%{
#define SWIG_exception(a,b)   { Tcl_SetResult(interp,b,TCL_VOLATILE); SWIG_fail; }
%}
#else
#ifdef SWIGTCL
%{
#define SWIG_exception(a,b)   { Tcl_SetResult(interp,b,TCL_VOLATILE); return TCL_ERROR; }
%}
#endif
#endif

#ifdef SWIGPERL5
%{
#define SWIG_exception(a,b)   SWIG_croak(b)
%}
#endif

#ifdef SWIGPHP4
%{
/* We should make use of "code" if we can */
#define SWIG_exception(code, msg) { zend_error(E_ERROR, msg); }
%}
#endif

#ifdef SWIGPYTHON
%{
SWIGINTERN void SWIG_exception_(int code, const char *msg) {
  switch(code) {
  case SWIG_MemoryError:
    PyErr_SetString(PyExc_MemoryError,msg);
    break;
  case SWIG_IOError:
    PyErr_SetString(PyExc_IOError,msg);
    break;
  case SWIG_RuntimeError:
    PyErr_SetString(PyExc_RuntimeError,msg);
    break;
  case SWIG_IndexError:
    PyErr_SetString(PyExc_IndexError,msg);
    break;
  case SWIG_TypeError:
    PyErr_SetString(PyExc_TypeError,msg);
    break;
  case SWIG_DivisionByZero:
    PyErr_SetString(PyExc_ZeroDivisionError,msg);
    break;
  case SWIG_OverflowError:
    PyErr_SetString(PyExc_OverflowError,msg);
    break;
  case SWIG_SyntaxError:
    PyErr_SetString(PyExc_SyntaxError,msg);
    break;
  case SWIG_ValueError:
    PyErr_SetString(PyExc_ValueError,msg);
    break;
  case SWIG_SystemError:
    PyErr_SetString(PyExc_SystemError,msg);
    break;
  default:
    PyErr_SetString(PyExc_RuntimeError,msg);
    break;
  }
}

#define SWIG_exception(a,b) { SWIG_exception_(a,b); SWIG_fail; }
%}
#endif

#ifdef SWIGGUILE
%{
  SWIGINTERN void SWIG_exception_ (int code, const char *msg,
                               const char *subr) {
#define ERROR(scmerr)					\
	scm_error(gh_symbol2scm((char *) (scmerr)),	\
		  (char *) subr, (char *) msg,		\
		  SCM_EOL, SCM_BOOL_F)
#define MAP(swigerr, scmerr)			\
	case swigerr:				\
	  ERROR(scmerr);			\
	  break
    switch (code) {
      MAP(SWIG_MemoryError,	"swig-memory-error");
      MAP(SWIG_IOError,		"swig-io-error");
      MAP(SWIG_RuntimeError,	"swig-runtime-error");
      MAP(SWIG_IndexError,	"swig-index-error");
      MAP(SWIG_TypeError,	"swig-type-error");
      MAP(SWIG_DivisionByZero,	"swig-division-by-zero");
      MAP(SWIG_OverflowError,	"swig-overflow-error");
      MAP(SWIG_SyntaxError,	"swig-syntax-error");
      MAP(SWIG_ValueError,	"swig-value-error");
      MAP(SWIG_SystemError,	"swig-system-error");
    default:
      ERROR("swig-error");
    }
#undef ERROR
#undef MAP
  }

#define SWIG_exception(a,b) SWIG_exception_(a, b, FUNC_NAME)
%}
#endif

#ifdef SWIGMZSCHEME

%{
SWIGINTERN void SWIG_exception_ (int code, const char *msg) {
#define ERROR(errname)				\
	scheme_signal_error(errname " (%s)", msg);
#define MAP(swigerr, errname)			\
	case swigerr:				\
	  ERROR(errname);			\
	  break
    switch (code) {
      MAP(SWIG_MemoryError,	"swig-memory-error");
      MAP(SWIG_IOError,		"swig-io-error");
      MAP(SWIG_RuntimeError,	"swig-runtime-error");
      MAP(SWIG_IndexError,	"swig-index-error");
      MAP(SWIG_TypeError,	"swig-type-error");
      MAP(SWIG_DivisionByZero,	"swig-division-by-zero");
      MAP(SWIG_OverflowError,	"swig-overflow-error");
      MAP(SWIG_SyntaxError,	"swig-syntax-error");
      MAP(SWIG_ValueError,	"swig-value-error");
      MAP(SWIG_SystemError,	"swig-system-error");
    default:
      ERROR("swig-error");
    }
#undef ERROR
#undef MAP
  }

#define SWIG_exception(a,b) SWIG_exception_(a, b)
%}
#endif

#ifdef SWIGJAVA
%{
SWIGINTERN void SWIG_JavaException(JNIEnv *jenv, int code, const char *msg) {
  SWIG_JavaExceptionCodes exception_code = SWIG_JavaUnknownError;
  switch(code) {
  case SWIG_MemoryError:
    exception_code = SWIG_JavaOutOfMemoryError;
    break;
  case SWIG_IOError:
    exception_code = SWIG_JavaIOException;
    break;
  case SWIG_SystemError:
  case SWIG_RuntimeError:
    exception_code = SWIG_JavaRuntimeException;
    break;
  case SWIG_OverflowError:
  case SWIG_IndexError:
    exception_code = SWIG_JavaIndexOutOfBoundsException;
    break;
  case SWIG_DivisionByZero:
    exception_code = SWIG_JavaArithmeticException;
    break;
  case SWIG_SyntaxError:
  case SWIG_ValueError:
  case SWIG_TypeError:
    exception_code = SWIG_JavaIllegalArgumentException;
    break;
  case SWIG_UnknownError:
  default:
    exception_code = SWIG_JavaUnknownError;
    break;
  }
  SWIG_JavaThrowException(jenv, exception_code, msg);
}
#define SWIG_exception(nullreturn, code, msg) { SWIG_JavaException(jenv, code, msg); return nullreturn; }
%}
#endif // SWIGJAVA

#ifdef SWIGOCAML
%{
#define OCAML_MSG_BUF_LEN 1024
SWIGINTERN void SWIG_exception_(int code, const char *msg) {
  char msg_buf[OCAML_MSG_BUF_LEN];
  sprintf( msg_buf, "Exception(%d): %s\n", code, msg );
  failwith( msg_buf );  
}
#define SWIG_exception(a,b) SWIG_exception_((a),(b))
%}
#endif

#ifdef SWIGRUBY
%{
SWIGINTERN void SWIG_exception_(int code, const char *msg) {
    switch (code) {
        case SWIG_MemoryError:
            rb_raise(rb_eNoMemError, msg);
            break;
        case SWIG_IOError:
            rb_raise(rb_eIOError, msg);
            break;
        case SWIG_RuntimeError:
            rb_raise(rb_eRuntimeError, msg);
            break;
        case SWIG_IndexError:
            rb_raise(rb_eIndexError, msg);
            break;
        case SWIG_TypeError:
            rb_raise(rb_eTypeError, msg);
            break;
        case SWIG_DivisionByZero:
            rb_raise(rb_eZeroDivError, msg);
            break;
        case SWIG_OverflowError:
            rb_raise(rb_eRangeError, msg);
            break;
        case SWIG_SyntaxError:
            rb_raise(rb_eSyntaxError, msg);
            break;
        case SWIG_ValueError:
            rb_raise(rb_eArgError, msg);
            break;
        case SWIG_SystemError:
            rb_raise(rb_eFatal, msg);
            break;
        case SWIG_UnknownError:
            rb_raise(rb_eRuntimeError, msg);
            break;
        default:
            break;
    }
}

#define SWIG_exception(a, b) SWIG_exception_((a), (b))
%}
#endif

#ifdef SWIGCHICKEN
%{
SWIGINTERN void SWIG_exception_(int code, const char *msg) {
  C_word *a;
  C_word scmmsg;
  C_word list;

  a = C_alloc (C_SIZEOF_STRING (strlen (msg)) + C_SIZEOF_LIST(2));
  scmmsg = C_string2 (&a, (char *) msg);
  list = C_list(&a, 2, C_fix(code), scmmsg);
  SWIG_ThrowException(list);
}
#define SWIG_exception(a,b) SWIG_exception_((a),(b))
%}
#endif

#ifdef SWIGCSHARP
%{
SWIGINTERN void SWIG_CSharpException(int code, const char *msg) {
  if (code == SWIG_ValueError) {
    SWIG_CSharpExceptionArgumentCodes exception_code = SWIG_CSharpArgumentOutOfRangeException;
    SWIG_CSharpSetPendingExceptionArgument(exception_code, msg, 0);
  } else {
    SWIG_CSharpExceptionCodes exception_code = SWIG_CSharpApplicationException;
    switch(code) {
    case SWIG_MemoryError:
      exception_code = SWIG_CSharpOutOfMemoryException;
      break;
    case SWIG_IndexError:
      exception_code = SWIG_CSharpIndexOutOfRangeException;
      break;
    case SWIG_DivisionByZero:
      exception_code = SWIG_CSharpDivideByZeroException;
      break;
    case SWIG_IOError:
      exception_code = SWIG_CSharpIOException;
      break;
    case SWIG_OverflowError:
      exception_code = SWIG_CSharpOverflowException;
      break;
    case SWIG_RuntimeError:
    case SWIG_TypeError:
    case SWIG_SyntaxError:
    case SWIG_SystemError:
    case SWIG_UnknownError:
    default:
      exception_code = SWIG_CSharpApplicationException;
      break;
    }
    SWIG_CSharpSetPendingException(exception_code, msg);
  }
}
#define SWIG_exception(nullreturn, code, msg) { SWIG_CSharpException(code, msg); return nullreturn; }
%}
#endif // SWIGCSHARP

#ifdef __cplusplus
/*
  You can use the SWIG_CATCH_STDEXCEPT macro with the %exception
  directive as follows:

  %exception {
    try {
      $action
    }
    catch (my_except& e) {
      ...
    }
    SWIG_CATCH_STDEXCEPT // catch std::exception 
    catch (...) {
     SWIG_exception(SWIG_UnknownError, "Unknown exception");
    }
  }  
*/
%{
#include <stdexcept>
%}
%define SWIG_CATCH_STDEXCEPT
  /* catching std::exception  */
  catch (std::invalid_argument& e) {
    SWIG_exception(SWIG_ValueError, e.what() );
  } catch (std::domain_error& e) {
    SWIG_exception(SWIG_ValueError, e.what() );
  } catch (std::overflow_error& e) {
    SWIG_exception(SWIG_OverflowError, e.what() );
  } catch (std::out_of_range& e) {
    SWIG_exception(SWIG_IndexError, e.what() );
  } catch (std::length_error& e) {
    SWIG_exception(SWIG_IndexError, e.what() );
  } catch (std::runtime_error& e) {
    SWIG_exception(SWIG_RuntimeError, e.what() );
  } catch (std::exception& e) {
    SWIG_exception(SWIG_SystemError, e.what() );
  }
%enddef
%define SWIG_CATCH_UNKNOWN
  catch (std::exception& e) {
    SWIG_exception(SWIG_SystemError, e.what() );
  }
  catch (...) {
    SWIG_exception(SWIG_UnknownError, "unknown exception");
  }
%enddef


#endif /* __cplusplus */

/* exception.i ends here */
