%module(directors="1") director_frob;
#pragma SWIG nowarn=SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR

%header %{
#include <iostream>
%}

%feature("director");
%feature("nodirector") Bravo::abs_method();   // ok
%feature("director")   Charlie::abs_method(); // ok
%feature("nodirector") Delta::abs_method();   // ok

%inline %{

  struct Alpha
  {
    virtual ~Alpha() { };
    virtual const char* abs_method() = 0;
  };
  
  struct Bravo : Alpha
  {
    const char* abs_method()
    {
      return "Bravo::abs_method()";
    }
  };

  struct Charlie : Bravo 
  {
    const char* abs_method()
    {
      return "Charlie::abs_method()";
    }
  };
  
  struct Delta : Charlie
  {
  };
%}

%rename(OpInt) operator int;

%inline %{
  class Ops {
  public:
    virtual ~Ops() {}
    virtual operator int() { return 0; }
  };
%}
