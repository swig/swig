%module(directors="1") director_nested

%{
#include <string>
#include <iostream>
%}

%include "std_string.i"

%feature("director") FooBar<int>;

%newobject *::create();

%inline %{
  template <class C>
    class Foo {
    public:
      virtual ~Foo() {}
      
      std::string advance() 
      {
	return "Foo::advance;" + do_advance();
      }  

    protected:
      virtual std::string do_advance() = 0;
    };
%}

%template(Foo_int) Foo<int>;

%inline %{

  class Bar : public Foo<int>
  {
  public:
    
    std::string step() 
    {
      return "Bar::step;" + advance();    
    }
    
  protected:
    std::string do_advance() 
    {
      return "Bar::do_advance;" + do_step();
    }
    

    virtual std::string do_step()  = 0;
  };  
  
  template <class C>
    class FooBar : public Bar
    {
    public:
      virtual C get_value() = 0;
    };
%}

%template(FooBar_int) FooBar<int>;

