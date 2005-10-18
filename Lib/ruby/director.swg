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

namespace Swig {
  struct body_args {
    VALUE recv;
    ID id;
    int argc;
    VALUE *argv;
  };
  
  /* Base class for director exceptions */
  class DirectorException {
  protected:
    VALUE swig_error;
    std::string swig_msg;
  protected:
    DirectorException(VALUE error)
      : swig_error(error)
    {
    }
    
    DirectorException(VALUE error, const char* hdr, const char* msg ="") 
      : swig_error(error), swig_msg(hdr) {
      if (strlen(msg)) {
	swig_msg += " ";
	swig_msg += msg;
      }
      if (swig_msg.size()) {
	VALUE str = rb_str_new2(swig_msg.c_str());
	swig_error = rb_exc_new3(error, str);
      } else {
	swig_error = error;
      }
    }
  public:
    VALUE getType() const  { 
      return CLASS_OF(swig_error); 
    }
    VALUE getError() const {
      return swig_error;
    }
    virtual ~DirectorException() {}
  };
  
  /* Type mismatch in the return value from a Ruby method call */
  class DirectorTypeMismatchException : public Swig::DirectorException {
  public:
    DirectorTypeMismatchException(VALUE error, const char *msg="")
      : Swig::DirectorException(error, "Swig director type mismatch", msg) 
    {
    }

    DirectorTypeMismatchException(const char *msg="")
      : Swig::DirectorException(rb_eTypeError, "Swig director type mismatch", msg) 
    {
    }

    static void raise(VALUE error, const char *msg) {
      throw DirectorTypeMismatchException(error, msg);
    }

    static void raise(const char *msg) {
      throw DirectorTypeMismatchException(msg);
    }
  };

  /* Any Ruby exception that occurs during a director method call */
  class DirectorMethodException : public Swig::DirectorException {
  public:
    DirectorMethodException(VALUE error) 
      : Swig::DirectorException(error) {
    }

    DirectorMethodException(const char* msg = "") 
      : Swig::DirectorException(rb_eRuntimeError, "Swig director method error", msg) {
    }
    
    static void raise(VALUE error)
    {
      throw DirectorMethodException(error);
    }    
  };

  /* Attempted to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public Swig::DirectorException
  {
  public:
    DirectorPureVirtualException(const char* msg = "") 
      : DirectorException(rb_eRuntimeError, "Swig director pure virtal method called", msg)
    { 
    }

    static void raise(const char *msg) 
    {
      throw DirectorPureVirtualException(msg);
    }
  };

  /* Simple thread abstraction for pthreads on win32 */
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
      /* pointer to the wrapped Ruby object */
      VALUE swig_self;
      /* flag indicating whether the object is owned by Ruby or c++ */
      mutable bool swig_disown_flag;
      /* shared flag for breaking recursive director calls */
      static bool swig_up;

#ifdef __PTHREAD__
      /* locks for sharing the swig_up flag in a threaded environment */
      static pthread_mutex_t swig_mutex_up;
      static bool swig_mutex_active;
      static pthread_t swig_mutex_thread;
#endif

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
      /* wrap a Ruby object, optionally taking ownership */
      Director(VALUE self) : swig_self(self), swig_disown_flag(false) {
      }

      /* discard our reference at destruction */
      virtual ~Director() {
      }

      /* return a pointer to the wrapped Ruby object */
      VALUE swig_get_self() const { 
        return swig_self; 
      }

      /* get the swig_up flag to determine if the method call should be routed
       * to the c++ base class or through the wrapped Ruby object
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
        return false;
      }
#else 
      bool swig_get_up() const { 
        bool up = swig_up;
        swig_up = false;
        return up;
      }
#endif

      /* set the swig_up flag if the next method call should be directed to
       * the c++ base class rather than the wrapped Ruby object
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

      /* acquire ownership of the wrapped Ruby object (the sense of "disown"
       * is from Ruby) */
      void swig_disown() const { 
        if (!swig_disown_flag) { 
          swig_disown_flag = true;
        } 
      }
  };

  bool Swig::Director::swig_up = false;

#ifdef __PTHREAD__
  MUTEX_INIT(Swig::Director::swig_mutex_up);
  pthread_t Swig::Director::swig_mutex_thread;
  bool Swig::Director::swig_mutex_active = false;
#endif

}

#endif /* __cplusplus */


