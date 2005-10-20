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
#include <iostream>
#include <exception>


/*
  Use -DSWIG_DIRECTOR_NOUEH if you prefer to avoid the use of the
  Undefined Exception Handler provided by swift
*/
#ifndef SWIG_DIRECTOR_NOUEH
#ifndef SWIG_DIRECTOR_UEH
#define SWIG_DIRECTOR_UEH
#endif
#endif


/*
  Use -DSWIG_DIRECTOR_STATIC if you prefer to avoid the use of the
  'Swig' namespace. This could be usefull for multi-modules projects.
*/
#ifdef SWIG_DIRECTOR_STATIC
/* Force anonymous (static) namespace */
#define Swig
#endif


/*
  Use -DSWIG_DIRECTOR_NORTTI if you prefer to avoid the use of the
  native C++ RTTI and dynamic_cast<>. But be aware that directors
  could stop working when using this option.
*/
#ifdef SWIG_DIRECTOR_NORTTI
/* 
   When we don't use the native C++ RTTI, we implement a minimal one
   only for Directors.
*/
# ifndef SWIG_DIRECTOR_RTDIR
# define SWIG_DIRECTOR_RTDIR
#include <map>
namespace Swig {
  class Director;
  SWIGINTERN std::map<void*,Director*>& get_rtdir_map() {
    static std::map<void*,Director*> rtdir_map;
    return rtdir_map;
  }

  SWIGINTERNINLINE void set_rtdir(void *vptr, Director *rtdir) {
    get_rtdir_map()[vptr] = rtdir;
  }

  SWIGINTERNINLINE Director *get_rtdir(void *vptr) {
    std::map<void*,Director*>::const_iterator pos = get_rtdir_map().find(vptr);
    Director *rtdir = (pos != get_rtdir_map().end()) ? pos->second : 0;
    return rtdir;
  }
}
# endif /* SWIG_DIRECTOR_RTDIR */

# define SWIG_DIRECTOR_CAST(Arg) Swig::get_rtdir(static_cast<void*>(Arg))
# define SWIG_DIRECTOR_RGTR(Arg1, Arg2) Swig::set_rtdir(static_cast<void*>(Arg1), Arg2)

#else

# define SWIG_DIRECTOR_CAST(Arg) dynamic_cast<Swig::Director*>(Arg)
# define SWIG_DIRECTOR_RGTR(Arg1, Arg2)

#endif /* SWIG_DIRECTOR_NORTTI */

extern "C" {
  struct swig_type_info;
}

namespace Swig {  

  /* base class for director exceptions */
  class DirectorException {
  protected:
    std::string swig_msg;
  public:
    DirectorException(PyObject *error, const char* hdr ="", const char* msg ="") 
      : swig_msg(hdr)
    {
      if (strlen(msg)) {
	swig_msg += " ";
	swig_msg += msg;
      }
      if (!PyErr_Occurred()) {
	PyErr_SetString(error, getMessage());
      } else {
	SWIG_Python_AddErrorMsg(getMessage());
      }
    }

    const char *getMessage() const
    { 
      return swig_msg.c_str(); 
    }

    static void raise(PyObject *error, const char *msg) 
    {
      throw DirectorException(error, msg);
    }

    static void raise(const char *msg) 
    {
      raise(PyExc_RuntimeError, msg);
    }
  };

  /* unknown exception handler  */
  class UnknownExceptionHandler 
  {
    static void handler();    
  public:
    
#ifdef SWIG_DIRECTOR_UEH
    std::unexpected_handler old;
    UnknownExceptionHandler(std::unexpected_handler nh = handler)
    {
      old = std::set_unexpected(nh);
    }

    ~UnknownExceptionHandler()
    {
      std::set_unexpected(old);
    }
#endif
  };

  /* type mismatch in the return value from a python method call */
  class DirectorTypeMismatchException : public Swig::DirectorException {
  public:
    DirectorTypeMismatchException(PyObject *error, const char* msg="") 
      : Swig::DirectorException(error, "Swig director type mismatch", msg)
    {
    }

    DirectorTypeMismatchException(const char* msg="") 
      : Swig::DirectorException(PyExc_TypeError, "Swig director type mismatch", msg)
    {
    }

    static void raise(PyObject *error, const char *msg)
    {
      throw DirectorTypeMismatchException(error, msg);
    }

    static void raise(const char *msg)
    {
      throw DirectorTypeMismatchException(msg);
    }
  };

  /* any python exception that occurs during a director method call */
  class DirectorMethodException : public Swig::DirectorException {
  public:
    DirectorMethodException(const char* msg = "") 
      : DirectorException(PyExc_RuntimeError, "Swig director method error", msg)
    {
    }    

    static void raise(const char *msg)
    {
      throw DirectorMethodException(msg);
    }
  };

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public Swig::DirectorException
  {
  public:
    DirectorPureVirtualException(const char* msg = "") 
      : DirectorException(PyExc_RuntimeError, "Swig director pure virtal method called", msg)
    { 
    }

    static void raise(const char *msg) 
    {
      throw DirectorPureVirtualException(msg);
    }
  };


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
