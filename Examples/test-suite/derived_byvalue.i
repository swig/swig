%module derived_byvalue

%inline %{

struct Foo {
  int x;

  // this works
  int rmethod(const Foo& f) { return f.x; }

  // this doesn't when DerFoo (below) is introduced
  int method(Foo f) { return f.x; }
};

struct Bar {
   Foo   a;
   struct Foo b;
};

/*
  When the next derived class is declared, the 
  following bad method is generated

  static void *_DerFooTo_Foo(void *x) {   // **** bad ****
    return (void *)((Foo)  ((DerFoo) x));
  }

  static void *_p_DerFooTo_p_Foo(void *x) {   // *** good ***
    return (void *)((Foo *)  ((DerFoo *) x));
  }
  
  if the derived class is deleted, it works again 

  if the previos Foo::method

 */
struct DerFoo : Foo {
};

#
%}
