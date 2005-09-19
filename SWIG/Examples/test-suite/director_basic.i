%module(directors="1") director_basic
%{
#include <string>

class Foo {
public:
	virtual ~Foo() {}
	virtual std::string ping() { return "Foo::ping()"; }
	virtual std::string pong() { return "Foo::pong();" + ping(); }
};

%}

%include "std_string.i"

%feature("director") Foo;


class Foo {
public:
	virtual ~Foo() {}
	virtual std::string ping() { return "Foo::ping()"; }
	virtual std::string pong() { return "Foo::pong();" + ping(); }
};

%{
#include <complex> 
%}
%feature("director");

// basic renaming
%rename(rg) A::gg;
%feature("nodirector") hi::A1::gg;

%inline %{

struct A{
    A(std::complex<int> i, double d=0.0) {}
    A(int i, bool j=false) {}
    virtual ~A() {}
    
    virtual int f(int i=0) {return i;}
    virtual int gg(int i=0) {return i;}
};

namespace hi  {

  struct A1 : public A {
    A1(std::complex<int> i, double d=0.0) : A(i, d) {}
    A1(int i, bool j=false) : A(i, j) {}
    
    virtual int ff(int i = 0) {return i;}  
  };
}
 

%}


%feature("director") MyClass;

%inline %{

typedef void VoidType;

class MyClass {
public:
  MyClass(int a = 0) 
  {
  }
  
  virtual void method(VoidType *)
  {
  }
  
  virtual ~MyClass()
  {
  }
  
};

template<class T>
class MyClassT {
public:
  MyClassT(int a = 0) 
  {
  }
  
  virtual void method(VoidType *)
  {
  }
  
  virtual ~MyClassT()
  {
  }
  
};

%}

%template(MyClassT_i) MyClassT<int>;
