%module template_construct

// Tests templates to make sure an extra <> in a constructor and destructor is ok.

%inline %{
template<class T>
class Foo {
    T y;
public:
#ifdef SWIG
    Foo<T>(T x) : y(x) { }
    ~Foo<T>() {}
#else
    // Modern compilers (C++20) reject this, so feed the compiler the corrected version
    Foo(T x) : y(x) { }
    ~Foo() {}
#endif
};

%}

%template(Foo_int) Foo<int>;

%inline %{
template<>
class Foo<short> {
    short y;
public:
#ifdef SWIG
    Foo<short>(short x) : y(x) { }
    Foo<short>() : y(0) { }
    virtual ~Foo<short>() {}
#else
    // Modern compilers (C++20) reject this, so feed the compiler the corrected version
    // version.
    Foo(short x) : y(x) { }
    Foo() : y(0) { }
    virtual ~Foo() {}
#endif
};
%}

%template(Foo_short) Foo<short>;
