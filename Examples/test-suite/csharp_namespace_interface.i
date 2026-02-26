%module csharp_namespace_interface

%nspace;

%{
  namespace A::B {
  class Interface {
    virtual std::string Method() = 0;
  };
}

namespace A {
  class Implementer : public A::B::Interface {
    virtual std::string Method() override { return "Implemented A::B::Interface::Method"; }
  };
}
%}

%include <swiginterface.i>

%interface_impl(A::B::Implementer);

namespace A::B {
  class Interface {
    virtual std::string Method();
  };
}

namespace A {
  class Implementer : public A::B::Interface {
    virtual std::string Method() override;
  };
}
