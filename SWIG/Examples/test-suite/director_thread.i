// This testcase was in the python subdirectory

#if defined(SWIGPYTHON)
// Is "threads" really needed for Python? It seems to work without it.
%module(directors="1",threads="1") director_thread
#else
%module(directors="1") director_thread
#endif

%{
#ifdef _WIN32
#include <windows.h>
#include <process.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#include <iostream>

class Foo;  
extern "C" {
  void* SWIGSTDCALL working(void* t);
}
%}

%director Foo;

%inline {
  static void MilliSecondSleep(int milliseconds) {
  #ifdef _WIN32
    Sleep(milliseconds);
  #else
    usleep(milliseconds*1000);
  #endif
  }

  class Foo {
  public:
    int val;
    pthread_t *t;
    unsigned int thread_id;
    
    Foo() : val(0), thread_id(0) {
      t = new pthread_t;
    }
    
    virtual ~Foo()  {
      delete t;
    }

    void run() {
#ifdef _WIN32
      _beginthreadex(NULL,0,run,this,0,&thread_id);
#else
      pthread_create(t,NULL,working,this);
#endif
      MilliSecondSleep(5000);
    }
    
    virtual void do_foo() {
      val += 1;
    }
  };
}

%inline %{
  extern "C" {
    void* working(void* t) {
    Foo* f = static_cast<Foo*>(t);
    while (1) {
      MilliSecondSleep(1000);
      f->do_foo();
    }
    return 0;
  }
}
%}
