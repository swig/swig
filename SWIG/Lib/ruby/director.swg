/***********************************************************************
 * director.swg
 *
 * This file contains support for director classes that proxy
 * method calls from C++ to Ruby extensions.
 *
 * Author : Lyle Johnson (lyle@users.sourceforge.net)
 *          Based on the original Python implementation by
 *          Mark Rose (mrose@stm.lbl.gov).
 ************************************************************************/

#ifdef __cplusplus

#include <string>

struct swig_body_args
{
  VALUE recv;
  ID id;
  int argc;
  VALUE *argv;
};

/* Base class for director exceptions */
class SWIG_DIRECTOR_EXCEPTION {
protected:
  VALUE _error;
protected:
  SWIG_DIRECTOR_EXCEPTION(VALUE error=Qnil) : _error(error) {}
public:
  VALUE getType() const  { return CLASS_OF(_error); }
  VALUE getError() const { return _error; }
  virtual ~SWIG_DIRECTOR_EXCEPTION() {}
};

/* Type mismatch in the return value from a Ruby method call */
class SWIG_DIRECTOR_TYPE_MISMATCH : public SWIG_DIRECTOR_EXCEPTION {
public:
  SWIG_DIRECTOR_TYPE_MISMATCH(const char *msg="") {
    VALUE str = rb_str_new2("Swig director type mismatch: ");
    rb_str_concat(str, rb_str_new2(msg));
    _error = rb_exc_new3(rb_eTypeError, str);
  }
};

/* Any Ruby exception that occurs during a director method call */
class SWIG_DIRECTOR_METHOD_EXCEPTION : public SWIG_DIRECTOR_EXCEPTION {
public:
  SWIG_DIRECTOR_METHOD_EXCEPTION(VALUE error) :SWIG_DIRECTOR_EXCEPTION(error) {}
};

/* Attempted to call a pure virtual method via a director method */
class SWIG_DIRECTOR_PURE_VIRTUAL_EXCEPTION : public SWIG_DIRECTOR_EXCEPTION {};


/* Simple thread abstraction for pthreads or win32 */
#ifdef __THREAD__
  #define __PTHREAD__
  #if defined(_WIN32) || defined(__WIN32__)
    #define pthread_mutex_lock EnterCriticalSection
    #define pthread_mutex_unlock LeaveCriticalSection
    #define pthread_mutex_t CRITICAL_SECTION
    #define MUTEX_INIT(var) CRITICAL_SECTION var
  #else
    #include <pthread.h>
    #define MUTEX_INIT(var) pthread_mutex_t var = PTHREAD_MUTEX_INITIALIZER 
  #endif
#endif

/* director base class */
class __DIRECTOR__ {
private:
  /* pointer to the wrapped Ruby object */
  VALUE _self;
  /* flag indicating whether the object is owned by Ruby or c++ */
  mutable bool _disown;
  /* shared flag for breaking recursive director calls */
  static bool _up;

#ifdef __PTHREAD__
  /* locks for sharing the _up flag in a threaded environment */
  static pthread_mutex_t _mutex_up;
  static bool _mutex_active;
  static pthread_t _mutex_thread;
#endif

  /* reset the _up flag once the routing direction has been determined */
#ifdef __PTHREAD__
  void __clear_up() const { 
    __DIRECTOR__::_up = false; 
    __DIRECTOR__::_mutex_active = false;
    pthread_mutex_unlock(&_mutex_up);
  }
#else
  void __clear_up() const { 
    __DIRECTOR__::_up = false; 
  }
#endif

public:
  /* wrap a Ruby object, optionally taking ownership */
  __DIRECTOR__(VALUE self, bool disown) : _self(self), _disown(disown) {
  }

  /* discard our reference at destruction */
  virtual ~__DIRECTOR__() {
  }
  
  /* return a pointer to the wrapped Ruby object */
  VALUE __get_self() const { 
    return _self; 
  }
  

  /* get the _up flag to determine if the method call should be routed
   * to the c++ base class or through the wrapped Ruby object
   */
#ifdef __PTHREAD__
  bool __get_up() const { 
    if (__DIRECTOR__::_mutex_active) {
      if (pthread_equal(__DIRECTOR__::_mutex_thread, pthread_self())) {
        bool up = _up;
        __clear_up();
        return up;
      }
    }
    return false;
  }
#else 
  bool __get_up() const { 
    bool up = _up;
    _up = false;
    return up;
  }
#endif
  
  /* set the _up flag if the next method call should be directed to
   * the c++ base class rather than the wrapped Ruby object
   */
#ifdef __PTHREAD__
  void __set_up() const { 
    pthread_mutex_lock(&__DIRECTOR__::_mutex_up);
    __DIRECTOR__::_mutex_thread = pthread_self();
    __DIRECTOR__::_mutex_active = true;
    __DIRECTOR__::_up = true;
  }
#else 
  void __set_up() const { 
    __DIRECTOR__::_up = true; 
  }
#endif

  /* acquire ownership of the wrapped Ruby object (the sense of "disown"
   * is from Ruby) */
  void __disown() const { 
    if (!_disown) { 
      _disown = true;
    } 
  }
};

bool __DIRECTOR__::_up = false;

#ifdef __PTHREAD__
  MUTEX_INIT(__DIRECTOR__::_mutex_up);
  pthread_t __DIRECTOR__::_mutex_thread;
  int __DIRECTOR__::_mutex_active = false;
#endif

#endif /* __cplusplus */


