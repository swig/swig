%module nspace_interface

// nspace feature only supported by these languages
#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGD) || defined(SWIGLUA) || defined(SWIGJAVASCRIPT)

// %interface only supported by these languages
#if defined(SWIGJAVA) || defined(SWIGCSHARP)

%nspace;

%include <std_string.i>
%include <swiginterface.i>

%interface_impl(A::B::Interface);

%inline %{
#include <string>

namespace A {
namespace B {
  class Interface {
  public:
    virtual std::string Method() = 0;
    virtual ~Interface() {};
  };
}
}

namespace A {
  class Implementer : public A::B::Interface {
  public:
    virtual std::string Method() { return "Implemented A::B::Interface::Method"; }
    virtual ~Implementer() {};
  };
}
%}

#endif

#else
//#warning nspace feature not yet supported in this target language
#endif
