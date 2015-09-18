%module(directors="1") director_smartptr

#ifdef SWIGJAVA
SWIG_JAVABODY_PROXY(public, public, SWIGTYPE)
SWIG_JAVABODY_TYPEWRAPPER(public, public, public, SWIGTYPE)
#endif

%{
#include <boost/shared_ptr.hpp>
#include <string>

class FooBar {
public:
  FooBar() {}
  FooBar(const FooBar&) {}
  virtual ~FooBar() {}

  std::string FooBarDo() { return "Bar::Foo2::Foo2Bar()"; }
};

class Foo {
public:
  virtual ~Foo() {}
  virtual std::string ping() { return "Foo::ping()"; }
  virtual std::string pong() { return "Foo::pong();" + ping(); }
  virtual std::string fooBar(FooBar* fooBarPtr) { return fooBarPtr->FooBarDo(); }
  virtual Foo makeFoo() { return Foo(); }
  virtual FooBar makeFooBar() { return FooBar(); }

  static Foo* get_self(Foo *self_) {return self_;}
};

%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON) || defined(SWIGD) || defined(SWIGOCTAVE) || defined(SWIGRUBY)
#define SHARED_PTR_WRAPPERS_IMPLEMENTED
#endif

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)

%include <std_string.i>
%include <boost_shared_ptr.i>

%shared_ptr(Foo)

%feature("director") Foo;

class FooBar {
public:
  FooBar();
  FooBar(const FooBar&);
  virtual ~FooBar();
  
  std::string FooBarDo();
  
};

class Foo
{
public:
  virtual ~Foo();
  virtual std::string ping();
  virtual std::string pong();
  virtual std::string fooBar(FooBar* fooBarPtr);
  virtual Foo makeFoo();
  virtual FooBar makeFooBar();
 
  static Foo* get_self(Foo *self_);
};

#endif

