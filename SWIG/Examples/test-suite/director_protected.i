%module(directors="1",dirprot="1") director_protected

%{
#include <string>
#include <iostream>
%}

%include "std_string.i"

%feature("director") Foo;
%feature("director") Bar;

%newobject *::create();

%inline {
class Foo {
public:
  virtual ~Foo() {}
  virtual std::string pong() {
    return "Foo::pong();" + ping();
  }
protected:

  virtual std::string ping() = 0;

  void hellom() {}

  virtual void used() {}  
};

class Bar : public Foo 
{
public:
  Foo* create() 
  {
    return new Bar();
  }

  std::string pong() {
    return "Bar::pong();" + Foo::pong();
  }

  int hello;

  using Foo::used;
  
protected:
  std::string ping() { 
    return "Bar::ping();"; 
  };
  
  int hi;
  void him() {}
};
 
 
}

