/* This was broken in the perl module.  See bug 962115 
It tests basic multiple inheritance */

%module(ruby_minherit="1") multiple_inheritance


#ifdef SWIGJAVA
#pragma SWIG nowarn=813; // Java doesn't support multiple  inheritance
#endif

#ifdef SWIGCSHARP
#pragma SWIG nowarn=833; // C# doesn't support multiple  inheritance
#endif

%inline %{

class Bar {
public:
  virtual ~Bar()
  {
  }
  
  virtual int bar() { return 1; }
};

class Foo {
public:
  virtual ~Foo()
  {
  }

  virtual int foo() { return 2; }
};

class FooBar : public Foo, public Bar {
public:
  virtual int fooBar() { return 3; }
};

%}
