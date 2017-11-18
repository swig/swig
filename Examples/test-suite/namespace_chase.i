%module namespace_chase

%inline %{
  namespace Space1A {
    struct Struct1A {};
    namespace Space1B {
      struct Struct1B {};
      namespace Space1C {
        struct Struct1C {};
      }
    }
  }
  namespace Space2A {
    using namespace Space1A;
    namespace Space2B {
      using namespace Space1B;
      namespace Space2C {
        using namespace Space1C;
      }
    }
  }
  namespace Space3 {
    using namespace Space2A;
    void sss3a(Space1A::Struct1A, Space1A::Space1B::Struct1B, Space1A::Space1B::Space1C::Struct1C) {}
    void sss3b(Struct1A, Space1B::Struct1B, Space1B::Space1C::Struct1C) {}
    // To fix: the last two parameters below fail and result in SWIGTYPE_ types instead of proxy classes
    void sss3c(Space2A::Struct1A, Space2A::Space1B::Struct1B, Space2A::Space1B::Space1C::Struct1C) {}
  }
  namespace Space4 {
    using namespace Space2A;
    using namespace Space2A::Space2B;
    using namespace Space2A::Space2B::Space2C;
    void sss4a(Struct1A, Struct1B, Space2C::Struct1C) {}
    void sss4b(Struct1A, Struct1B, Struct1C) {}
  }
%}
