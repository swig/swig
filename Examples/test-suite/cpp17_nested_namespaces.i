%module cpp17_nested_namespaces
// Tests c++17 style nested namespaces
// Tests are designed so that code compiles with C++98 compilers

#define CPP17 1
%{
#if __cplusplus >= 201703L
#define CPP17 1
#endif
%}

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
#if defined(CPP17)
namespace A1::B1 {
#else
namespace A1 {
 namespace B1 {
#endif
  A1Struct createA1Struct() { return ::A1::A1Struct(); }
  B1Struct createB1Struct() { return ::A1::B1::B1Struct(); }
#if !defined(CPP17)
 }
}
#else
}
#endif

namespace A1 {
  namespace B1 {
    namespace C1 {
      struct C1Struct {
        void C1Method() {}
      };
    }
  }
}

#if defined(CPP17)
namespace A1::B1::C1 {
#else
namespace A1 {
 namespace B1 {
  namespace C1 {
#endif
  C1Struct createC1Struct() { return ::A1::B1::C1::C1Struct(); }
#if !defined(CPP17)
  }
 }
}
#else
}
#endif
%}

%inline %{
// Tests with namespaces already defined using C++17 style (nested) namespaces
#if defined(CPP17)
namespace A2::B2 {
#else
namespace A2 {
 namespace B2 {
#endif
  struct B2Struct {
    void B2Method() {}
  };
#if !defined(CPP17)
 }
}
#else
}
#endif

#if defined(CPP17)
namespace A2::B2 {
#else
namespace A2 {
 namespace B2 {
#endif
  B2Struct createB2Struct() { return ::A2::B2::B2Struct(); }
#if !defined(CPP17)
 }
}
#else
}
#endif

#if defined(CPP17)
namespace A2::B2::C2 {
#else
namespace A2 {
 namespace B2 {
  namespace C2 {
#endif
    struct C2Struct {
      void C2Method() {}
    };
#if !defined(CPP17)
  }
 }
}
#else
}
#endif

#if defined(CPP17)
namespace A2::B2::C2 {
#else
namespace A2 {
 namespace B2 {
  namespace C2 {
#endif
  C2Struct createC2Struct() { return ::A2::B2::C2::C2Struct(); }
#if !defined(CPP17)
  }
 }
}
#else
}
#endif
%}


%inline %{
// Tests with namespaces already defined using C++17 style (nested) namespaces to 3 levels
#if defined(CPP17)
namespace A3::B3::C3 {
#else
namespace A3 {
 namespace B3 {
  namespace C3 {
#endif
    struct C3Struct {
      void C3Method() {}
    };
#if !defined(CPP17)
  }
 }
}
#else
}
#endif

#if defined(CPP17)
namespace A3::B3::C3 {
#else
namespace A3 {
 namespace B3 {
  namespace C3 {
#endif
  C3Struct createC3Struct() { return ::A3::B3::C3::C3Struct(); }
#if !defined(CPP17)
  }
 }
}
#else
}
#endif

#if defined(CPP17)
namespace A3::B3 {
#else
namespace A3 {
 namespace B3 {
#endif
  struct B3Struct {
    void B3Method() {}
  };
#if !defined(CPP17)
 }
}
#else
}
#endif

#if defined(CPP17)
namespace A3::B3 {
#else
namespace A3 {
 namespace B3 {
#endif
  B3Struct createB3Struct() { return ::A3::B3::B3Struct(); }
#if !defined(CPP17)
 }
}
#else
}
#endif
%}
