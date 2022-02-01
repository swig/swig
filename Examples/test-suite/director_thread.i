// This testcase was in the python subdirectory

#if defined(SWIGPYTHON)
// Is "threads" really needed for Python? It seems to work without it.
%module(directors="1",threads="1") director_thread
#else
%module(directors="1") director_thread
#endif

#ifdef SWIGOCAML
%warnfilter(SWIGWARN_PARSE_KEYWORD) val;
#endif

%begin %{
#define SWIG_JAVA_USE_THREAD_NAME
//#define DEBUG_DIRECTOR_THREAD_NAME
%}

%{
#ifdef _WIN32
#include <windows.h>
#include <process.h>
#else
#include <pthread.h>
#include <errno.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#endif

#include <assert.h>
#include <stdio.h>
#include "swig_examples_lock.h"

class Foo;  
extern "C" {
#ifdef _WIN32
  static unsigned int __stdcall working(void* t);
  static HANDLE thread_handle = 0;
#else
  void* working(void* t);
  static pthread_t thread;
#endif

  static int swig_thread_terminate = 0;
  static SwigExamples::CriticalSection critical_section;
  int get_thread_terminate() {
    SwigExamples::Lock lock(critical_section);
    return swig_thread_terminate;
  }
  void set_thread_terminate(int value) {
    SwigExamples::Lock lock(critical_section);
    swig_thread_terminate = value;
  }
}
%}

%director Foo;

%inline {
  static void MilliSecondSleep(int milliseconds) {
  %#ifdef _WIN32
    Sleep(milliseconds);
  %#else
    usleep(milliseconds*1000);
  %#endif
  }

  class Foo {
  public:
    int val;
    
    Foo() : val(0) {
    }
    
    virtual ~Foo()  {
    }

    void stop() {
      set_thread_terminate(1);
    %#ifdef _WIN32
      WaitForSingleObject(thread_handle, INFINITE);
      CloseHandle(thread_handle);
    %#else  
      pthread_join(thread, NULL);
    %#endif
    }

    void run() {
%#ifdef _WIN32
      unsigned int thread_id = 0;
      thread_handle = (HANDLE)_beginthreadex(NULL,0,working,this,0,&thread_id);
      if (thread_handle == 0) {
        fprintf(stderr, "_beginthreadex failed in run()\n");
        assert(0);
      }
%#else
      int create = pthread_create(&thread,NULL,working,this);
      if (create != 0) {
        errno = create;
        perror("pthread_create in run()");
        assert(0);
      }
%#endif
      MilliSecondSleep(500);
    }

    void setThreadName() {
%#ifdef _WIN32
%#else

%#ifdef __APPLE__
      int setname = pthread_setname_np("MyThreadName");
%#else
      int setname = pthread_setname_np(pthread_self(), "MyThreadName");
%#endif

      if (setname != 0) {
        errno = setname;
        perror("calling pthread_setname_np in setThreadName()");
        assert(0);
      }
%#endif
    }

    static bool namedThread() {
%#ifdef _WIN32
      return false;
%#else
      return true;
%#endif
    }

    virtual void do_foo() {
      val += 1;
    }
  };
}

%{
extern "C" {
#ifdef _WIN32
  unsigned int __stdcall working(void* t)
#else
  void* working(void* t)
#endif
  {
    Foo* f = static_cast<Foo*>(t);
    f->setThreadName();
    while (!get_thread_terminate()) {
      MilliSecondSleep(50);
      f->do_foo();
    }
    return 0;
  }
}
%}
