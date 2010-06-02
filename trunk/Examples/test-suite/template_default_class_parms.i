%module template_default_class_parms

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
