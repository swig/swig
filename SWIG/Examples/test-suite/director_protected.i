%module(directors="1",dirprot="1") director_protected

%{
#include <string>
#include <iostream>
%}

%include "std_string.i"

%feature("director") Foo;
%feature("director") Bar;

%newobject *::create();

%rename(a) Bar::hello;

%inline {
class Foo {
public:
  virtual ~Foo() {}
  virtual std::string pong() {
    return "Foo::pong();" + ping();
  }
protected:
  Foo() {}  

  virtual std::string ping() = 0;

  virtual std::string pang() 
  {
    return "Foo::pang();"; 
  }

  void hellom() {}

  virtual std::string used() {
    return pang() + pong();
  }
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

  enum Hello {hola, chao};

  static int a;
  static const int b;
  
  int hi;
  void him() {}

private:
  int c;

};
 
 
}

