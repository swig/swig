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

