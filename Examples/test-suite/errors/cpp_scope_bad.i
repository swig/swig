%module xxx

template <typename Tnum>
class Space::A<Tnum>::Anest {
public:
    Anest();
};

namespace N {
  template<typename T> class C {};
}
namespace unrelated {
  %template(cin) N::C<int>;
  template class N::C<int>;
}
struct Outer {
    struct Unrelated<X>  {
      %template(cin) N::C<int>;
      template class N::C<int>;
    };
};

struct ::X::Y<int> {
};

using namespace Nope<double>;

template<typename T>
struct NotANamespace {
};
%template(NotANamespaceInt) NotANamespace<int>;
%template() NotANamespace<double>;

using namespace NotANamespace<double>;

namespace BadEquivalent = NotANamespace<int>;
namespace AwfulEquivalent = Nope<double>;
