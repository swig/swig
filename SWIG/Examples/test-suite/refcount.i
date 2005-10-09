%module refcount

%warnfilter(362);

%{ 
#include <iostream> 
#include "refcount.h"
%}

//
// using the %refobject/%unrefobject directives you can active the
// ref. counting for RCObj and all its descendents at once
//

%refobject   RCObj "$this->addref();"
%unrefobject RCObj "$this->delref();"

%include "refcount.h"

%newobject B::create(A* a);
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
    
    A* get_a() 
    {
      return _a;
    }
    
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
