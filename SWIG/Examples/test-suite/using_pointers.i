%module using_pointers

%inline %{
  class Foo {
  public:
    int x;
    virtual ~Foo() { }
    virtual Foo* blah() { return this; }
  };

  class FooBar : public Foo {
  public:
    using Foo::blah;
    using Foo::x;
  };

%}

