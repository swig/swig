#ifndef SWIG_DIRECTOR_PYTHON_HEADER_
#define SWIG_DIRECTOR_PYTHON_HEADER_
/***********************************************************************
 * director_h.swg
 *
 *     This file contains support for director classes that proxy
 *     method calls from C++ to Python extensions.
 *
 * Author : Mark Rose (mrose@stm.lbl.gov)
 ************************************************************************/

#ifdef __cplusplus

#include <string>

extern "C" {
  struct swig_type_info;
}

#ifdef SWIG_DIRECTOR_STATIC
/* Force anonymous (static) namespace */
#define Swig
#endif

namespace Swig {
  /* base class for director exceptions */
  class DirectorException {
  protected:
    std::string swig_msg;
  public:
    DirectorException(const char* /* msg */ ="") {
    }

    const char *getMessage() const { 
      return swig_msg.c_str(); 
    }

    virtual ~DirectorException();    
  };

  /* type mismatch in the return value from a python method call */
  class DirectorTypeMismatchException : public Swig::DirectorException {
  public:
    DirectorTypeMismatchException(const char* msg="") {
      if (!PyErr_Occurred()) {
	swig_msg = "Swig director type mismatch: ";
	swig_msg += msg;
	PyErr_SetString(PyExc_TypeError, getMessage());
      }
    }
  };

  /* any python exception that occurs during a director method call */
  class DirectorMethodException : public Swig::DirectorException {};

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public Swig::DirectorException {};


  /* simple thread abstraction for pthreads on win32 */
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
  class Director {
  private:
    /* pointer to the wrapped python object */
    PyObject* swig_self;
    /* flag indicating whether the object is owned by python or c++ */
    mutable bool swig_disown_flag;
    /* shared flag for breaking recursive director calls */
    static bool swig_up;

#ifdef __PTHREAD__
    /* locks for sharing the swig_up flag in a threaded environment */
    static pthread_mutex_t swig_mutex_up;
    static bool swig_mutex_active;
    static pthread_t swig_mutex_thread;
#endif

    /* decrement the reference count of the wrapped python object */
    void swig_decref() const { 
      if (swig_disown_flag) {
	Py_DECREF(swig_self); 
      }
    }

    /* reset the swig_up flag once the routing direction has been determined */
#ifdef __PTHREAD__
    void swig_clear_up() const { 
      Swig::Director::swig_up = false; 
      Swig::Director::swig_mutex_active = false;
      pthread_mutex_unlock(&swig_mutex_up);
    }
#else
    void swig_clear_up() const { 
      Swig::Director::swig_up = false; 
    }
#endif

  public:
    /* wrap a python object, optionally taking ownership */
    Director(PyObject* self) : swig_self(self), swig_disown_flag(false) {
      swig_incref();
    }

    /* discard our reference at destruction */
    virtual ~Director();

    /* return a pointer to the wrapped python object */
    PyObject *swig_get_self() const { 
      return swig_self; 
    }

    /* get the swig_up flag to determine if the method call should be routed
     * to the c++ base class or through the wrapped python object
     */
#ifdef __PTHREAD__
    bool swig_get_up() const { 
      if (Swig::Director::swig_mutex_active) {
	if (pthread_equal(Swig::Director::swig_mutex_thread, pthread_self())) {
	  bool up = swig_up;
	  swig_clear_up();
	  return up;
	}
      }
      return 0;
    }
#else 
    bool swig_get_up() const { 
      bool up = swig_up;
      swig_up = false;
      return up;
    }
#endif

    /* set the swig_up flag if the next method call should be directed to
     * the c++ base class rather than the wrapped python object
     */
#ifdef __PTHREAD__
    void swig_set_up() const { 
      pthread_mutex_lock(&Swig::Director::swig_mutex_up);
      Swig::Director::swig_mutex_thread = pthread_self();
      Swig::Director::swig_mutex_active = true;
      Swig::Director::swig_up = true; 
    }
#else 
    void swig_set_up() const { 
      Swig::Director::swig_up = true; 
    }
#endif

    /* acquire ownership of the wrapped python object (the sense of "disown"
     * is from python) */
    void swig_disown() const { 
      if (!swig_disown_flag) { 
	swig_disown_flag=true;
	swig_incref(); 
      } 
    }

    /* increase the reference count of the wrapped python object */
    void swig_incref() const { 
      if (swig_disown_flag) {
	Py_INCREF(swig_self); 
      }
    }

    /* methods to implement pseudo protected director members */
    virtual bool swig_get_inner(const char* /* name */) const {
      return true;
    }
    
    virtual void swig_set_inner(const char* /* name */, bool /* val */) const {
    }
  };

}

#endif /* __cplusplus */


#endif
