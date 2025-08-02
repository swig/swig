/* -----------------------------------------------------------------------------
 * director_py_mutex.swg
 *
 * contains python mutex for threads
 * ----------------------------------------------------------------------------- */

#if defined(SWIG_PYTHON_THREADS) && !defined(SWIG_THREADS)
#define SWIG_THREADS 1
#endif
#if defined(SWIG_THREADS) && !defined(Py_LIMITED_API)
#include "pythread.h"
#define SWIG_HAVE_MUTEX
namespace Swig {
   class Mutex
   {
       PyThread_type_lock mutex_;
   public:
       Mutex() : mutex_(PyThread_allocate_lock()) {}
       ~Mutex() { PyThread_free_lock(mutex_); }
       void lock() { PyThread_acquire_lock(mutex_, WAIT_LOCK); }
       void unlock() { PyThread_release_lock(mutex_); }
   };
}
#endif
