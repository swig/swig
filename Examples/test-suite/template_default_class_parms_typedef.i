%module template_default_class_parms_typedef

// Based on template_default_class_parms testcase but using typedefs in template

%feature("python:nondynamic");

%inline %{
namespace Space {
  struct SomeType {};
  struct AnotherType {};
  template<typename CC, typename DD = SomeType, typename EE = int> class Bar {
  public:
    typedef CC C;
    typedef DD D;
    typedef EE E;
    C CType;
    D DType;
    E EType;
    // Use typedef with no qualifiers
    Bar(C c, D d, E e) {}
    C method(C c, D d, E e) { return c; }

    // Use typedef with classname qualifiers
    Bar(bool, Bar::C c, Bar::D d, Bar::E e) {}
    Bar::C method_1(Bar::C c, Bar::D d, Bar::E e) { return c; }

    // Use typedef with classname and full template parameter qualifiers
    Bar(bool, bool, Bar<CC, DD, EE>::C c, Bar<CC, DD, EE>::D d, Bar<CC, DD, EE>::E e) {}
    Bar<CC, DD, EE>::C method_2(Bar<CC, DD, EE>::C c, Bar<CC, DD, EE>::D d, Bar<CC, DD, EE>::E e) { return c; }

    // Use typedef with namespace and classname and full template parameter qualifiers
    Bar(bool, bool, bool, Space::Bar<CC, DD, EE>::C c, Space::Bar<CC, DD, EE>::D d, Space::Bar<CC, DD, EE>::E e) {}
    Space::Bar<CC, DD, EE>::C method_3(Space::Bar<CC, DD, EE>::C c, Space::Bar<CC, DD, EE>::D d, Space::Bar<CC, DD, EE>::E e) { return c; }
  };
  template<typename TT = SomeType> class Foo {
  public:
    typedef TT T;
    T TType;

    // Use typedef with no qualifiers
    Foo(T t) {}
    T method(T t) { return t; }

    // Use typedef with classname qualifiers
    Foo(const T &, T t) {}
    Foo::T method_A(Foo::T t) { return t; }

    // Use typedef with classname and full template parameter qualifiers
    Foo(const Foo<TT>::T &, const Foo<TT>::T &, Foo<TT>::T t) {}
    Foo<TT>::T method_B(Foo<TT>::T t) { return t; }

    // Use typedef with namespace and classname and full template parameter qualifiers
    Foo(const Foo<TT>::T &, const Foo<TT>::T &, const Foo<TT>::T &, Foo<TT>::T t) {}
    Foo<TT>::T method_C(Foo<TT>::T t) { return t; }
  };
  template<typename T = int> class ATemplate {};

  template<typename T> struct UsesBar {
    void use_A(typename Bar<T>::C, typename Bar<T>::D, typename Bar<T>::E) {}
    void use_B(const typename Bar<T>::C &, const typename Bar<T>::D &, const typename Bar<T>::E &) {}
    void use_C(typename Space::Bar<T>::C, typename Space::Bar<T>::D, typename Space::Bar<T>::E) {}
    void use_D(const typename Space::Bar<T>::C &, const typename Space::Bar<T>::D &, const typename Space::Bar<T>::E &) {}
  };
}
%}

// Use defaults
%template(DefaultBar) Space::Bar<double>;
%template(DefaultFoo) Space::Foo<>;

// Don't use all defaults
%template(BarAnotherTypeBool) Space::Bar<Space::AnotherType, bool>;
%template(FooAnotherType) Space::Foo<Space::AnotherType>;

%template() Space::ATemplate<>;

%template(UsesBarDouble) Space::UsesBar<double>;
