%module csharp_nspace_interface

%nspace;

%include <std_string.i>
%include <swiginterface.i>

%interface_impl(A::B::Interface);

%inline %{
#include <string>

namespace A::B {
  class Interface {
  public:
    virtual std::string Method() = 0;
    virtual ~Interface() {};
  };
}

namespace A {
  class Implementer : public A::B::Interface {
  public:
    virtual std::string Method() { return "Implemented A::B::Interface::Method"; }
    virtual ~Implementer() {};
  };
}
%}
