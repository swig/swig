%module(directors="1") frob;

%header %{
#include <iostream>
%}

%feature("director");
%feature("nodirector") Bravo::abs_method(); // ok
%feature("director") Charlie::abs_method(); // ok
%feature("nodirector") Delta::abs_method(); // doesn't work

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
