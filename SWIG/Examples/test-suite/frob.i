%module(directors="1") frob;

%header %{
#include <iostream>
%}

%feature("director") Alpha;
%feature("director") Bravo;

%feature("nodirector") Bravo::abs_method();

%inline %{
  class Alpha
  {
  public:
    Alpha() { }
    virtual ~Alpha() { };
    virtual const char* abs_method() = 0;
  };

  class Bravo : public Alpha
  {
  public:
    Bravo() { }
    virtual ~Bravo() { };
    virtual const char* abs_method();
  };

  const char*
  Bravo::abs_method()
  {
    return "Bravo::abs_method()";
  }
%}
