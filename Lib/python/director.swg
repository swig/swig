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
  /* base class for director exceptions */
  DirectorException::~DirectorException() {
  }

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

}

#endif /* __cplusplus */

