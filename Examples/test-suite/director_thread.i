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
#ifdef _WIN32
  unsigned int __stdcall working(void* t);
  unsigned int thread_id(0);
#else
  void* working(void* t);
  pthread_t thread;
#endif
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

    void run() {
%#ifdef _WIN32
      _beginthreadex(NULL,0,working,this,0,&thread_id);
%#else
      pthread_create(&thread,NULL,working,this);
%#endif
      MilliSecondSleep(500);
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
    while (1) {
      MilliSecondSleep(50);
      f->do_foo();
    }
    return 0;
  }
}
%}
