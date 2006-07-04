%module(directors="1") explicitcall

%include <std_string.i>

%director;

%explicitcall;
%feature("explicitcall", suffix="Bambino") Space::GrandChild::talk;

%inline %{

#include <string>
namespace Space {
  struct Person {
    Person() {}
    virtual std::string talk() { return "Person"; }
    virtual ~Person() {}
  };

  struct Child : Person {
    void nonvirtual() {}
    virtual std::string talk () { return "Child"; }
  };

  struct GrandChild : Child {
    virtual std::string talk() { return "GrandChild"; }
  };
}
%}

%cleardirector;

// a template and default parameters test
%inline %{
template<class T> class Template {
public:
  virtual ~Template(){}
  virtual T bar(const int &t = int(20)) const { return "Template"; }
};
%}

%template(TemplateString) Template<std::string>; 

%inline %{
struct TDerived : Template<std::string> {
  virtual std::string bar(const int &t = int(20)) const { return "TDerived"; }
};
%}

