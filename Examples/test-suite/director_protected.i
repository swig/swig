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

#if defined(SWIGPYTHON) || defined(SWIGRUBY) \
  || defined(SWIGJAVA) || defined(SWIGOCAML)
  virtual std::string ping() = 0;
#else
  virtual std::string ping() { return "";};
#endif

  void hellom() {}
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

protected:
  std::string ping() { 
    return "Bar::ping();"; 
  };
  
  int hi;
  void him() {}
};
 
 
}

