%module(directors="1") director_thread

%{
#include <pthread.h>
#include <iostream>

class Foo;  
extern "C" void* working(void* t);
%}


%feature("director") Foo;

%inline {
  class Foo {
  public:
    int val;
    Foo() : val(0) {}
    
    virtual ~Foo()  {}

    void run() {
      pthread_t *t = new pthread_t;
      pthread_create(t,NULL,working,this);
      sleep(5);
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
  }
}
