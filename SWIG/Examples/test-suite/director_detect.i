%module(directors="1") director_detect
#pragma SWIG nowarn=470

%warnfilter(822, 842) cloner; /* Java, C# covariant return types */

%{
#include <string>
#include <iostream>
%}

%include "std_string.i"

%feature("director") Bar;

%newobject Foo::cloner();
%newobject Bar::cloner();


%inline {
  namespace foo { typedef int Int; }
  
  struct A
  {
  };
  
  typedef A B;
  
  struct Foo {
    virtual ~Foo() {}
    virtual Foo* cloner() = 0;
    virtual int get_value() = 0;
    virtual A* get_class() = 0;

    virtual void just_do_it() = 0;
  };
  
  class Bar : public Foo
  {
  public:    
    Foo* baseclass() 
    {
      return this;
    }    
    
    Bar* cloner()
    {
      return new Bar();
    }
    
    
    foo::Int get_value() 
    {
      return 1;
    }

    B* get_class() 
    {
      return new B();
    }

    void just_do_it() 
    {
    }
  };  
}



