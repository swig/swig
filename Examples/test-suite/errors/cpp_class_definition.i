%module xxx



namespace OtherSpace {
  struct L;
}
namespace Space11 {
  namespace SubSpace11 {
    using OtherSpace::L;
    struct L {
      void ll();
    };
  }
}


namespace Space1 {
  struct A;
}
namespace Space2 {
  struct Space1::A {
    void x();
  };
}

namespace Space2 {
    struct B;
}

struct ::Space2::B {
    int val;
    B() : val() {}
};

struct XX;
// g++: error: global qualification of class name is invalid before ‘{’ token
struct ::XX {
  int vvv;
};
