%module using_directive_and_declaration_forward
// Test using directives combined with using declarations and forward declarations

%inline %{
namespace Outer1 {
  namespace Space1 {
    class Thing1;
  }
}
using namespace Outer1::Space1;
using Outer1::Space1::Thing1;
class Thing1 {};
void useit1(Thing1 t) {}
void useit1a(Outer1::Space1::Thing1 t) {}
void useit1b(::Outer1::Space1::Thing1 t) {}
namespace Outer1 {
  void useit1c(Space1::Thing1 t) {}
}


namespace Outer2 {
  namespace Space2 {
    class Thing2;
  }
}
using namespace Outer2;
using Space2::Thing2;
class Thing2 {};
void useit2(Thing2 t) {}
void useit2a(Outer2::Space2::Thing2 t) {}
void useit2b(::Outer2::Space2::Thing2 t) {}
void useit2c(Space2::Thing2 t) {}
namespace Outer2 {
  void useit2d(Space2::Thing2 t) {}
}


namespace Outer3 {
  namespace Space3 {
    namespace Middle3 {
      class Thing3;
    }
  }
}
using namespace Outer3;
using namespace Space3;
using Middle3::Thing3;
class Thing3 {};
void useit3(Thing3 t) {}
void useit3a(Outer3::Space3::Middle3::Thing3 t) {}
void useit3b(::Outer3::Space3::Middle3::Thing3 t) {}
void useit3c(Middle3::Thing3 t) {}
namespace Outer3 {
  namespace Space3 {
    void useit3d(Middle3::Thing3 t) {}
  }
}


namespace Outer4 {
  namespace Space4 {
    namespace Middle4 {
      class Thing4;
    }
  }
}
using namespace Outer4::Space4;
using Middle4::Thing4;
class Thing4 {};
void useit4(Thing4 t) {}
void useit4a(Outer4::Space4::Middle4::Thing4 t) {}
void useit4b(::Outer4::Space4::Middle4::Thing4 t) {}
void useit4c(Middle4::Thing4 t) {}
namespace Outer4 {
  namespace Space4 {
    void useit4d(Middle4::Thing4 t) {}
  }
}


namespace Outer5 {
  namespace Space5 {
    namespace Middle5 {
      namespace More5 {
        class Thing5;
      }
    }
  }
}
using namespace ::Outer5::Space5;
using namespace Middle5;
using More5::Thing5;
class Thing5 {};
void useit5(Thing5 t) {}
void useit5a(Outer5::Space5::Middle5::More5::Thing5 t) {}
void useit5b(::Outer5::Space5::Middle5::More5::Thing5 t) {}
void useit5c(Middle5::More5::Thing5 t) {}
namespace Outer5 {
  namespace Space5 {
    void useit5d(Middle5::More5::Thing5 t) {}
  }
}

namespace Outer7 {
  namespace Space7 {
    namespace Middle7 {
      class Thing7;
    }
  }
}
using namespace Outer7::Space7;
class Middle7::Thing7 {};
using Middle7::Thing7;
void useit7(Thing7 t) {}
void useit7a(Outer7::Space7::Middle7::Thing7 t) {}
void useit7b(::Outer7::Space7::Middle7::Thing7 t) {}
void useit7c(Middle7::Thing7 t) {}
namespace Outer7 {
  namespace Space7 {
    void useit7d(Middle7::Thing7 t) {}
  }
}

%}
