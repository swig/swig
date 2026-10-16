%module template_default_class_parms

#ifdef SWIGOCAML
%warnfilter(SWIGWARN_PARSE_KEYWORD) method;
#endif

%inline %{
namespace Space {
  struct SomeType {};
  struct AnotherType {};
  template<typename C, typename D = SomeType, typename E = int> class Bar {
  public:
    C CType;
    D DType;
    E EType;
    Bar(C c, D d, E e) {}
    C method(C c, D d, E e) { return c; }
  };
  template<typename T = SomeType> class Foo {
  public:
    T TType;
    Foo(T t) {}
    T method(T t) { return t; }
  };
  template<typename T = int> class ATemplate {};
}
%}

// Use defaults
%template(DefaultBar) Space::Bar<double>;
%template(DefaultFoo) Space::Foo<>;

// Don't use all defaults
%template(BarAnotherTypeBool) Space::Bar<Space::AnotherType, bool>;
%template(FooAnotherType) Space::Foo<Space::AnotherType>;

%template() Space::ATemplate<>;

// A default that is an earlier parameter, whose argument has the same name as a later parameter
%inline %{
namespace Space {
  struct Second {
    int value;
  };
  template<typename First, typename Second, typename Third = First> class Defaulted {
  public:
    Second second;
    Third third;
    Defaulted() : second(), third() {}
    Third copy_third() { return third; }
  };
  int third_value(Defaulted<Second, int> *d) { return d->copy_third().value; }
}
%}

%template(DefaultedSecondInt) Space::Defaulted<Space::Second, int>;

// All the arguments defaulted, with a default that is an earlier parameter
%inline %{
namespace Space {
  template<typename T> struct Box {
    T item;
  };
  template<typename Value = int, typename Boxed = Box<Value> > class AllDefaulted {
  public:
    Boxed boxed;
    AllDefaulted() : boxed() {}
  };
  int all_defaulted_item(AllDefaulted<> *a) { return a->boxed.item; }
}
%}

%template(BoxInt) Space::Box<int>;
%template(AllDefaultedInt) Space::AllDefaulted<>;


// Github issue #280 segfault
%inline %{
namespace Teuchos {
  class Describable {};
}
namespace KokkosClassic {
  namespace DefaultNode {
    struct DefaultNodeType {};
  }
}

namespace Tpetra {
  template <class LocalOrdinal = int,
            class GlobalOrdinal = LocalOrdinal,
            class Node = KokkosClassic::DefaultNode::DefaultNodeType>
  class Map : public Teuchos::Describable {
  public:
    typedef LocalOrdinal local_ordinal_type;
    typedef GlobalOrdinal global_ordinal_type;
    typedef Node node_type;
    void test_func(LocalOrdinal, GlobalOrdinal, Node) {}
  };
}
%}

#ifdef SWIGJAVA
// Fixes still required for other languages
%template(MapDefaults) Tpetra::Map<>;
#endif

%inline %{
namespace Details {
  template < class LO = ::Tpetra::Map<>::local_ordinal_type,
            class GO = typename ::Tpetra::Map<LO>::global_ordinal_type,
            class NT = typename ::Tpetra::Map<LO, GO>::node_type >
  class Transfer : public Teuchos::Describable {
  public:
    void transfer_func(LO, GO, NT) {}
  };
}
%}

// Below is not resolving correctly yet
//%template(TransferDefaults) Details::Transfer<>;
