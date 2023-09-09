// A class with a private assignment operator.
// This is rare, but sometimes used with singletons and
// objects that have complicated state.

%module private_assign
%{
#include <stdlib.h>
%}

%inline %{
   class Foo {
   private:
       Foo &operator=(const Foo &f) {
           return *this;
       }
   public:
       Foo() { }
       Foo(const Foo &f) { } // copy ctor can still be public, however.
       void bar() { }
   };

   Foo blah() {
      return Foo();
   }

  class Bar : protected Foo
  {
  };

%}

#pragma SWIG nowarn=SWIGWARN_IGNORE_OPERATOR_NEW // operator new

%inline %{
  class TROOT {
  protected:
     void *operator new(size_t l) { return malloc(sizeof(TROOT)); }
   
    int prot_meth() 
    {
      return 1;
    }
    
  public:
    TROOT()
    {
    }

    TROOT(const char *name, const char *title, void *initfunc = 0)
    {
    }
  };

  class A : protected TROOT
  {
  };
%}

%inline %{
   Foo foo_global;
   Foo foo_global_array[1];
   Foo foo_global_array_2d[2][2];

   struct FooBar : Foo 
   {
   };
   
   FooBar bar;
   FooBar bar_array[1];
   FooBar bar_array_2d[2][2];
%}

// https://sourceforge.net/p/swig/bugs/1006/
%rename(Assign) TwoIsAssignableCopyable::operator=;
%inline %{
struct nocopy {
  nocopy() {}
private:
  nocopy(const nocopy&);
  nocopy& operator=(const nocopy&);
};

struct One: public nocopy {};
struct TwoNotAssignableCopyable: public One {};
struct TwoIsAssignableCopyable: public One {
  TwoIsAssignableCopyable() {}
  TwoIsAssignableCopyable(const TwoIsAssignableCopyable&) {}
  TwoIsAssignableCopyable& operator=(const TwoIsAssignableCopyable&) { return *this; }
};
struct Three {
  TwoNotAssignableCopyable TwoNot; // getter only should be generated
  TwoIsAssignableCopyable TwoIs; // setter and getter should be generated
};
%}
