%module refcount

#pragma SWIG nowarn=362
%{ 
#include <iostream> 
#include "refcount.h"
%}

#if 1
//
// the old macro way
//
%define RefCount(...)
  %typemap(newfree) __VA_ARGS__* { $1->ref(); }
  %newobject __VA_ARGS__::clone();
  %extend __VA_ARGS__ { ~__VA_ARGS__() { self->unref(); } }
  %ignore __VA_ARGS__::~__VA_ARGS__();
%enddef
//
// you need to apply the RefCount macro to all the RCObj derived
// classes.
//
RefCount(RCObj);
RefCount(A);
RefCount(A1);
RefCount(A2);
RefCount(A3);
RefCount(B);

#else
//
// using the ref/unref features you can active the ref. counting
// for RCObj and all its descendents at once
//
%feature("refbase")   RCObj "$this->ref();"
%feature("unrefbase") RCObj "$this->unref();"

#endif

%include "refcount.h"

%newobject B::create();
%newobject B::cloner();

%inline %{

  struct A : RCObj
  {
    A() {}
    
    ~A() 
    {
      // std::cout << "deleting a" << std::endl;
    }

#ifdef SWIGRUBY 
    // fix strange ruby + virtual derivation problem
    using RCObjBase::ref_count;
#endif
  };

  struct A1 : A 
  {
  protected:
    A1() {}
  };

  struct A2 : A
  {
  };

  struct A3 : A1, private A2
  {    
  };
  
  struct B : RCObj
  {
    B(A* a) : _a(a) {}
    
    static B* create(A* a)
    {
      return new B(a);
    }
    
    B* cloner() 
    {
      return new B(_a);
    }

    ~B() 
    {
      // std::cout << "deleting b" << std::endl;
    }

  private:
    RCPtr<A> _a;
  };

%}


/* Other ref/unref uses:

// deactive the refcounting for A1 
%feature("noref")   A1;
%feature("nounref") A1;

// deactive the refcounting for A2 and all its descendents 
%feature("norefbase")   A2;
%feature("nounrefbase") A2;

// active the refcounting only for A3 
%feature("ref")   A3 { $this->ref(); }     
%feature("unref") A3 { $this->unref(); }

*/
