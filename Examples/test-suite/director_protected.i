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
%rename(s) Foo::p;
%rename(q) Foo::r;

%inline {
class Foo {
public:
  virtual ~Foo() {}
  virtual std::string pong() {
    return "Foo::pong();" + ping();
  }

  int p(){ return 1;}
  int r(){ return 1;}
    
  
protected:
  
  typedef int q(); 
  static int s(); 
  
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

  virtual std::string cheer() {
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

  std::string callping() {
    return ping();
  }

  std::string callcheer() {
    return cheer();
  }

  std::string pong() {
    return "Bar::pong();" + Foo::pong();
  }

  int hello;

  using Foo::used;
  
protected:
  std::string ping() { 
    return "Bar::ping();"; 
  }
  using Foo::cheer;

  enum Hello {hola, chao};

  static int a;
  static const int b;
  
  int hi;
  void him() {}

private:
  int c;

};
 

class PrivateFoo : private Foo 
{
};

}


%director A;
%director B;

%inline %{
  class A {
  public:
    A() {}
    virtual ~A() {}
  protected:
    virtual void draw() {}
  };

  class B : public A {
  public:
    B() {}
    virtual ~B() {}
  protected:
    void draw() {}
    void draw(int arg1) {}
  };

%}


%cleardirector;

%inline %{
  class AA {
  public:
    AA() {}
    virtual ~AA() {}
  protected:
    virtual void draw() {}
    virtual void plot() {}
  };

  class BB : public AA {
  public:
    BB() {}
    virtual ~BB() {}
  protected:
    void draw() {}
    void draw(int arg1) {}

    void plot(int arg1) {}
    void plot() {}
  };
%}

// A protected nested class, directed and deriving from a class used elsewhere in the wrapped API.
// No target language wraps a non-public nested class (regardless of dirprot/directors), but a
// runtime upcast helper for it used to get generated anyway, naming it by its inaccessible
// qualified name - a C++ compile error. See nested_scope.i's protectedbase block for the same
// bug without directors involved.
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) NestedOuter::NestedDerived;
%feature("director") NestedOuter::NestedDerived;

%inline %{
  class NestedBase {
  public:
    virtual ~NestedBase() {}
    virtual int identify() { return 0; }
  };

  class NestedOuter {
  protected:
    class NestedDerived : public NestedBase {
    public:
      NestedDerived() {}
      virtual int identify() { return 1; }
      virtual int vmethod(int x) { return x; }
    protected:
      virtual int protectedvmethod(int x) { return x; }
    };
  public:
    virtual ~NestedOuter() {}
    virtual NestedBase *makeDerived() { return new NestedDerived(); }
  };
%}
