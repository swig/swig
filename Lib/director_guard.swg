/* -----------------------------------------------------------------------------
 * director_guard.swg
 *
 * Generic Mutex implementation
 *
 * Before calling the file, you may choose the following:
 * - SWIG_THREADS:
 *   If set than we use mutexs.
 *   If not set we do not use mutexs.
 * - SWIG_HAVE_MUTEX:
 *   If you have a language defined 'Mutex' class, set this flag.
 *     The language 'Mutex' class need to be a Basic Lockable.
 *     It must have public 'void lock()' and 'void unlock()' methods.
 *     See: https://en.cppreference.com/w/cpp/named_req/BasicLockable
 *   If the flag is unset, use one of the following in that order:
 *   - C++ 11 or above, use std::mutex.
 *   - Win32 use CRITICAL_SECTION.
 *   - Use POSIX Pthread mutex.
 *
 * ----------------------------------------------------------------------------- */

#ifdef SWIG_THREADS

#if __cplusplus >= 201103L
/*
 * C++ 11 or above
 * std::mutex        https://en.cppreference.com/w/cpp/thread/mutex
 * std::unique_lock  https://en.cppreference.com/w/cpp/thread/unique_lock
 */
#include <mutex>
#ifdef SWIG_HAVE_MUTEX
/* Use Language defined Mutex class */
#define SWIG_GUARD(_mutex) std::unique_lock<Mutex> _guard(_mutex)
#define SWIG_GUARD_DEFINITION(_cls, _mutex) Mutex _cls::_mutex
#define SWIG_GUARD_DECLARATION(_mutex) static Mutex _mutex
#else
#define SWIG_GUARD(_mutex) std::unique_lock<std::mutex> _guard(_mutex)
#define SWIG_GUARD_DEFINITION(_cls, _mutex) std::mutex _cls::_mutex
#define SWIG_GUARD_DECLARATION(_mutex) static std::mutex _mutex
#endif

#else /* __cplusplus */

#ifdef SWIG_HAVE_MUTEX
/* Use Language defined Mutex class */

#elif defined(_WIN32)
/*
 * Windows Critical Section Objects
 * https://learn.microsoft.com/en-us/windows/win32/Sync/critical-section-objects
 */
#include <windows.h>
#include <synchapi.h>
namespace Swig {
    class Mutex {
        CRITICAL_SECTION mutex_;
    public:
        Mutex() { InitializeCriticalSection(&mutex_); }
        ~Mutex() { DeleteCriticalSection(&mutex_); }
        void lock() { EnterCriticalSection(&mutex_); }
        void unlock() { LeaveCriticalSection(&mutex_); }
    };
}

#else /* _WIN32 */
/*
 * POSIX Thread mutex
 * https://pubs.opengroup.org/onlinepubs/7908799/xsh/pthread.h.html
 */
#include <pthread.h>
namespace Swig {
    class Mutex {
        pthread_mutex_t mutex_;
    public:
        Mutex() { pthread_mutex_init(&mutex_, NULL); }
        ~Mutex() { pthread_mutex_destroy(&mutex_); }
        void lock() { pthread_mutex_lock(&mutex_); }
        void unlock() { pthread_mutex_unlock(&mutex_); }
    };
}

#endif /* _WIN32 */

namespace Swig {
    class Unique_lock {
        Mutex &mutex_;
    public:
        Unique_lock(Mutex &_mutex) : mutex_(_mutex) { mutex_.lock(); }
        ~Unique_lock() { mutex_.unlock(); }
    };
}
#define SWIG_GUARD(_mutex) Unique_lock _guard(_mutex)
#define SWIG_GUARD_DEFINITION(_cls, _mutex) Mutex _cls::_mutex
#define SWIG_GUARD_DECLARATION(_mutex) static Mutex _mutex

#endif /* __cplusplus */

#else /* SWIG_THREADS */

#define SWIG_GUARD(_mutex)
#define SWIG_GUARD_DEFINITION(_cls, _mutex)
#define SWIG_GUARD_DECLARATION(_mutex)

#endif /* SWIG_THREADS */
