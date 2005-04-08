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
    virtual ~Foo() {}
    
    void run() {
      pthread_t *t = new pthread_t;
      pthread_create(t,NULL,working,this);
      sleep(5);
    }
    
    virtual void do_foo() {
      std::cout << "foo" << std::endl;
    }
  };
}

%inline {
  extern "C" void* working(void* t) {
    Foo* f = static_cast<Foo*>(t);  
    while (1) {
      sleep(1);
      std::cout << "invoked" << std::endl;
      f->do_foo();
    }
  }
}
