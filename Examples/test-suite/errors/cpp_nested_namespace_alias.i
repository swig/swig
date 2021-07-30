%module xxx

// C++17 nested namespaces

namespace A
{
  namespace B
  {
    void ab1();
  }
}
namespace A::B
{
    void ab2();
}
namespace AAlias = A;
namespace AAlias::B
{
    void ab3();
}
namespace A
{
  namespace BAlias = B;
  void ab4();
}
namespace A::BAlias
{
  void ab5();
}
namespace ABAlias = A::B;
namespace ABAlias
{
    void ab6();
}
