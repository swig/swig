/***********************************************************************
 * director.swg
 *
 *     This file contains support for director classes that proxy
 *     method calls from C++ to Python extensions.
 *
 * Author : Mark Rose (mrose@stm.lbl.gov)
 ************************************************************************/

#ifdef __cplusplus

namespace Swig {
  /* simple thread abstraction for pthreads on win32 */
  Director::~Director() {
    swig_decref(); 
  }

  bool Director::swig_up = false;

#ifdef __PTHREAD__
  MUTEX_INIT(Director::swig_mutex_up);
  pthread_t Director::swig_mutex_thread;
  bool Director::swig_mutex_active = false;
#endif


  void UnknownExceptionHandler::handler()  {
    try {
      throw;
    } catch (DirectorException& e) {
      std::cerr << "Swig Director exception caught: "<< e.getMessage() << std::endl;
    } catch (std::exception& e) {
      std::cerr << "std::exception caught: "<< e.what() << std::endl;
    } catch (...) {
      std::cerr << "Unknown exception caught." << std::endl;
    }
    std::cerr << "This exception was caught by the SWIG unexpected exception handler." << std::endl;
    std::cerr << "Try using %feature(\"director:except\") to avoid reaching this point." << std::endl;
    std::cerr << "Now your program will probably be terminated, bye." << std::endl;
    throw;
  }

}

#endif /* __cplusplus */

