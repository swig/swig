/***********************************************************************
 * director.swg
 *
 *     This file contains support for director classes that proxy
 *     method calls from C++ to Python extensions.
 *
 * Author : Mark Rose (mrose@stm.lbl.gov)
 ************************************************************************/

%insert(runtime) %{

#ifdef __cplusplus

#include <string>

/* base class for director exceptions */
class SWIG_DIRECTOR_EXCEPTION {
protected:
  std::string _msg;
public:
  SWIG_DIRECTOR_EXCEPTION(const char* msg="") {
  }
  const char *getMessage() { return _msg.c_str(); }
  virtual ~SWIG_DIRECTOR_EXCEPTION() { }
};

/* type mismatch in the return value from a python method call */
class SWIG_DIRECTOR_TYPE_MISMATCH: public SWIG_DIRECTOR_EXCEPTION {
public:
  SWIG_DIRECTOR_TYPE_MISMATCH(const char* msg="") {
    _msg = "Swig director type mismatch: ";
    _msg += msg;
    PyErr_SetString(PyExc_TypeError, msg);
  }
};

/* any python exception that occurs during a director method call */
class SWIG_DIRECTOR_METHOD_EXCEPTION: public SWIG_DIRECTOR_EXCEPTION { };

/* simple thread abstraction for pthreads or win32 */
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
  /* pointer to the wrapped python object */
  PyObject* _self;
  /* flag indicating whether the object is owned by python or c++ */
  mutable int _disown;
  /* shared flag for breaking recursive director calls */
  static int _up;

#ifdef __PTHREAD__
  /* locks for sharing the _up flag in a threaded environment */
  static pthread_mutex_t _mutex_up;
  static int _mutex_active;
  static pthread_t _mutex_thread;
#endif

  /* decrement the reference count of the wrapped python object */
  void __decref() const { 
    assert(_self); 
    if (_disown) {
      Py_DECREF(_self); 
    }
  }

  /* reset the _up flag once the routing direction has been determined */
#ifdef __PTHREAD__
  void __clear_up() const { 
    __DIRECTOR__::_up = 0; 
    __DIRECTOR__::_mutex_active = 0;
    pthread_mutex_unlock(&_mutex_up);
  }
#else
  void __clear_up() const { 
    __DIRECTOR__::_up = 0; 
  }
#endif

public:
  /* the default constructor should not be called */
  __DIRECTOR__() { 
    assert(0); 
  }
  
  /* wrap a python object, optionally taking ownership */
  __DIRECTOR__(PyObject* self, int disown): _self(self), _disown(disown) {
    __incref();
  }

  /* discard our reference at destruction */
  virtual ~__DIRECTOR__() {
    __decref(); 
  }
  
  /* return a pointer to the wrapped python object */
  PyObject *__get_self() const { 
    return _self; 
  }
  

  /* get the _up flag to determine if the method call should be routed
   * to the c++ base class or through the wrapped python object
   */
#ifdef __PTHREAD__
  int __get_up() const { 
    if (__DIRECTOR__::_mutex_active) {
      if (pthread_equal(__DIRECTOR__::_mutex_thread, pthread_self())) {
        int up = _up;
        __clear_up();
        return up;
      }
    }
    return 0;
  }
#else 
  int __get_up() const { 
    int up = _up;
    _up = 0;
    return up;
  }
#endif
  
  /* set the _up flag if the next method call should be directed to
   * the c++ base class rather than the wrapped python object
   */
#ifdef __PTHREAD__
  void __set_up() const { 
    pthread_mutex_lock(&__DIRECTOR__::_mutex_up);
    __DIRECTOR__::_mutex_thread = pthread_self();
    __DIRECTOR__::_mutex_active = 1;
    __DIRECTOR__::_up = 1; 
  }
#else 
  void __set_up() const { 
    __DIRECTOR__::_up = 1; 
  }
#endif

  /* acquire ownership of the wrapped python object (the sense of "disown"
   * is from python) */
  void __disown() const { 
    assert(_self); 
    if (!_disown) { 
      _disown=1;
       __incref(); 
    } 
  }

  /* increase the reference count of the wrapped python object */
  void __incref() const { 
    assert(_self); 
    if (_disown) {
      Py_INCREF(_self); 
    }
  }

};

int __DIRECTOR__::_up = 0;

#ifdef __PTHREAD__
  MUTEX_INIT(__DIRECTOR__::_mutex_up);
  pthread_t __DIRECTOR__::_mutex_thread;
  int __DIRECTOR__::_mutex_active = 0;
#endif

#endif /* __cplusplus */

%}

