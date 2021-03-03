%module xxx

// This should error but doesn't
#if 0
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
#endif

namespace Space1 {
  struct A;
}
namespace Space2 {
  struct Space1::A {
    void x();
  };
}

