/* -----------------------------------------------------------------------------
 * swigexceptions.swg
 *
 * Error handling common to all target languages, included by swigcommon.swg after the target language's
 * exception.swg, which defines SWIG_exception: the SWIG error codes, SWIG_exception_fail, the 'throws' typemap for
 * '...' and the SWIG_CATCH_STDEXCEPT and SWIG_CATCH_UNKNOWN macros.
 * ----------------------------------------------------------------------------- */

%insert("runtime") "swigerrors.swg"

/* SWIG_exception_fail is the same as SWIG_exception, as a SWIG preprocessor macro if SWIG_exception is one */
#ifdef SWIG_exception
#define SWIG_exception_fail(code, msg) SWIG_exception(code, msg)
#else
%insert("runtime") %{
#define SWIG_exception_fail(code, msg) SWIG_exception(code, msg)
%}
#endif

/* The support code for SWIG_exception is always brought in, so SWIG_exception can be used anywhere */
%fragment("SWIG_exception");

#ifdef __cplusplus
/* For SWIG_CATCH_STDEXCEPT and SWIG_CATCH_UNKNOWN */
%fragment("<stdexcept>");
%fragment("<typeinfo>");

%typemap(throws, noblock=1, canthrow=1) (...) {
  SWIG_exception(SWIG_RuntimeError, "unknown exception");
}

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
#endif /* __cplusplus */
