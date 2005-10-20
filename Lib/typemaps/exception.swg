// This SWIG library file provides language independent exception handling
%include <typemaps/swigmacros.swg>

%insert("runtime") {

  SWIG_define(SWIG_exception(code, msg),        
	      SWIG_block(SWIG_error(code, msg); SWIG_fail))

  SWIG_define(SWIG_contract_assert(expr, msg),  
	      if (!(expr)) { SWIG_error(SWIG_RuntimeError, msg); SWIG_fail; } else)

}

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
