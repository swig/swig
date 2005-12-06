%module(directors="1",threads="1") director_thread

%{
#include <pthread.h>
#include <iostream>

class Foo;  
extern "C" void* working(void* t);
%}

%director Foo;

%inline {
  class Foo {
  public:
    int val;
    pthread_t *t;
    
    Foo() : val(0) {
      t = new pthread_t;
    }
    
    virtual ~Foo()  {
      delete t;
    }

    void run() {
      pthread_create(t,NULL,working,this);
      sleep(2);
    }
    
    virtual void do_foo() {
      val += 1;
    }
  };
}

%inline {
  extern "C" void* working(void* t) {
    Foo* f = static_cast<Foo*>(t);
    while (1) {
      sleep(1);
      f->do_foo();
    }
    return 0;
  }
}
