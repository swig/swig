%module using_namespace_loop

%inline {
namespace A {}

namespace B {
using namespace A;
}

namespace A {
using namespace B;
typedef Foo Bar;
}
}
