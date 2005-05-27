%module using_pointers

#ifdef SWIGCSHARP
%csmethodmodifiers x "public new"
#endif

%inline %{
  class Foo {
  public:
    int x;
    virtual ~Foo() { }
    virtual Foo* blah() { return this; }
    virtual Foo* exception_spec(int what_to_throw) throw (int, const char *) {
      int num = 10;
      const char *str = "exception message";
      if (what_to_throw == 1) throw num;
      else if (what_to_throw == 2) throw str;
      return 0;
    }
  };

  class FooBar : public Foo {
  public:
    using Foo::blah;
    using Foo::x;
    using Foo::exception_spec;
  };

%}

