// Test a mix of forward class declarations, class definitions, using declarations and using directives.

%module class_scope_namespace

%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) H::HH;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Space8::I_::II;

%inline %{
struct A;
namespace Space1 {
  namespace SubSpace1 {
    struct A {
      void aa(Space1::SubSpace1::A, SubSpace1::A, A) {}
    };
    void aaa(Space1::SubSpace1::A, SubSpace1::A, A) {}
  }
}

namespace Space2 {
  struct B;
}
using Space2::B;
#ifdef __clang__
namespace Space2 {
  struct B {
    void bb(Space2::B, B) {}
  };
}
#else
struct B {
  void bb(Space2::B, B) {}
};
#endif
void bbb(Space2::B, B) {}

namespace Space3 {
  namespace SubSpace3 {
    struct C;
    struct D;
  }
}
struct C;
struct D;
namespace Space3 {
  struct C;
  struct SubSpace3::C {
    void cc(Space3::SubSpace3::C, SubSpace3::C) {}
  };
  using SubSpace3::D;
  struct SubSpace3::D {
    void dd(Space3::SubSpace3::D, SubSpace3::D, D) {}
  };
  void ccc(Space3::SubSpace3::C, SubSpace3::C) {}
  void ddd(Space3::SubSpace3::D, SubSpace3::D, D) {}
}

namespace Space4 {
  namespace SubSpace4 {
    struct E;
  }
}
using namespace Space4;
using SubSpace4::E;
// Was added to incorrect namespace in swig-3.0.12
struct SubSpace4::E {
  void ee(Space4::SubSpace4::E, SubSpace4::E, E) {}
};
void eee(Space4::SubSpace4::E, SubSpace4::E, E) {}

namespace Space5 {
  namespace SubSpace5 {
    namespace SubSubSpace5 {
      struct F;
    }
  }
}
namespace Space5 {
  using namespace SubSpace5;
  using SubSubSpace5::F;
  // Was added to incorrect namespace in swig-3.0.12
  struct SubSubSpace5::F {
    void ff(Space5::SubSpace5::SubSubSpace5::F, SubSpace5::SubSubSpace5::F, SubSubSpace5::F, F) {}
  };
  void fff(Space5::SubSpace5::SubSubSpace5::F, SubSpace5::SubSubSpace5::F, SubSubSpace5::F, F) {}
}

namespace Space6 {
  struct G;
  namespace SubSpace6 {
    struct G;
  }
}
namespace Space6 {
  struct SubSpace6::G {
    void gg(Space6::SubSpace6::G, SubSpace6::G) {}
  };
  void ggg(Space6::SubSpace6::G, SubSpace6::G) {}
}

struct HH;
struct H {
  struct HH {
    void hh(H::HH) {}
  };
};
void hhh(H::HH) {}

namespace Space8 {
  struct II;
  struct I_ {
    struct II {
      void ii(Space8::I_::II, I_::II) {}
    };
  };
  void iii(Space8::I_::II, I_::II) {}
}

struct J;
namespace Space9 {
  namespace SubSpace9 {
    struct J {
      void jj(Space9::SubSpace9::J, SubSpace9::J, J) {}
    };
    void jjj(Space9::SubSpace9::J, SubSpace9::J, J) {}
  }
}

namespace Space10 {
  struct K;
}
namespace Space10 {
  namespace SubSpace10 {
    struct K {
      void kk(Space10::SubSpace10::K, SubSpace10::K, K) {}
    };
    void kkk(Space10::SubSpace10::K, SubSpace10::K, K) {}
  }
}

namespace OtherSpace {
  struct L;
  struct M;
}
using OtherSpace::L;
namespace Space11 {
  using OtherSpace::M;
  namespace SubSpace11 {
    struct L {
      void ll(Space11::SubSpace11::L, SubSpace11::L, L) {}
    };
    void lll(Space11::SubSpace11::L, SubSpace11::L, L) {}
    struct M {
      void mm(Space11::SubSpace11::M, SubSpace11::M, M) {}
    };
    void mmm(Space11::SubSpace11::M, SubSpace11::M, M) {}
  }
}

%}

