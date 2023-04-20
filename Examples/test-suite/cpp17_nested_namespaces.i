%module cpp17_nested_namespaces
// Tests c++17 style nested namespaces

%inline %{
// Tests with namespaces already defined using C++98 style (non-nested) namespaces
namespace A1 {
  struct A1Struct {
    void A1Method() {}
  };
  namespace B1 {
    struct B1Struct {
      void B1Method() {}
    };
  }
}
namespace A1::B1 {
  A1Struct createA1Struct() { return ::A1::A1Struct(); }
  B1Struct createB1Struct() { return ::A1::B1::B1Struct(); }
}

namespace A1 {
  namespace B1 {
    namespace C1 {
      struct C1Struct {
        void C1Method() {}
      };
    }
  }
}

namespace A1::B1::C1 {
  C1Struct createC1Struct() { return ::A1::B1::C1::C1Struct(); }
}
%}

%inline %{
// Tests with namespaces already defined using C++17 style (nested) namespaces
namespace A2::B2 {
  struct B2Struct {
    void B2Method() {}
  };
}

namespace A2::B2 {
  B2Struct createB2Struct() { return ::A2::B2::B2Struct(); }
}

namespace A2::B2::C2 {
    struct C2Struct {
      void C2Method() {}
    };
}

namespace A2::B2::C2 {
  C2Struct createC2Struct() { return ::A2::B2::C2::C2Struct(); }
}
%}


%inline %{
// Tests with namespaces already defined using C++17 style (nested) namespaces to 3 levels
namespace A3::B3::C3 {
    struct C3Struct {
      void C3Method() {}
    };
}

namespace A3::B3::C3 {
  C3Struct createC3Struct() { return ::A3::B3::C3::C3Struct(); }
}

namespace A3::B3 {
  struct B3Struct {
    void B3Method() {}
  };
}

namespace A3::B3 {
  B3Struct createB3Struct() { return ::A3::B3::B3Struct(); }
}
%}
