/* -----------------------------------------------------------------------------
 * exception.i
 *
 * SWIG library file providing language independent exception handling
 * ----------------------------------------------------------------------------- */

#if defined(SWIGUTL)
#error "This version of exception.i should not be used"
#endif


%insert("runtime") "swigerrors.swg"


#ifdef SWIGPHP
%fragment("SWIG_exception_fail");
%{
#define SWIG_exception(code, msg) SWIG_exception_fail(code, msg)
%}
#endif

#ifdef SWIGGUILE
%fragment("SWIG_exception_fail");
%{
#define SWIG_exception(code, msg) SWIG_exception_fail(code, msg)
%}
#endif

#ifdef SWIGJAVA
%fragment("SWIG_exception_fail");

#define SWIG_exception(code, msg) SWIG_exception_fail(code, msg)
#endif // SWIGJAVA

#ifdef SWIGOCAML
%{
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
#define SWIG_exception(code, msg) SWIG_exception_fail(code, msg)
%}
%fragment("SWIG_exception_fail");
#endif


#ifdef SWIGCSHARP
%fragment("SWIG_exception_fail");

#define SWIG_exception(code, msg) SWIG_exception_fail(code, msg)
#endif // SWIGCSHARP

#ifdef SWIGLUA

%fragment("SWIG_exception_fail");
%{
#define SWIG_exception(code, msg) SWIG_exception_fail(code, msg)
%}

#endif // SWIGLUA

#ifdef SWIGD
%fragment("SWIG_exception_fail");

#define SWIG_exception(code, msg) SWIG_exception_fail(code, msg)
#endif // SWIGD

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
#include <typeinfo>
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
  } catch (std::bad_cast& e) {
    SWIG_exception(SWIG_TypeError, e.what() );
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

/* rethrow the unknown exception */

#if defined(SWIGCSHARP) || defined(SWIGD)
%typemap(throws,noblock=1, canthrow=1) (...) {
  SWIG_exception(SWIG_RuntimeError,"unknown exception");
}
#else
%typemap(throws,noblock=1) (...) {
  SWIG_exception(SWIG_RuntimeError,"unknown exception");
}
#endif

#endif /* __cplusplus */

/* exception.i ends here */
