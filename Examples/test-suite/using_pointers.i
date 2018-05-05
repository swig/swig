%module using_pointers

#ifdef SWIGCSHARP
%csmethodmodifiers x "public new"
#endif

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW2(T1, T2) throw(T1, T2)
%{
#define TESTCASE_THROW2(T1, T2)
%}

%inline %{
  class Foo {
  public:
    int x;
    virtual ~Foo() { }
    virtual Foo* blah() { return this; }
    virtual Foo* exception_spec(int what_to_throw) TESTCASE_THROW2(int, const char *) {
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

