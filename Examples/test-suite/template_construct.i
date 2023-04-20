%module template_construct

// Tests templates to make sure an extra <> in a constructor is ok.

%inline %{
template<class T> 
class Foo {
    T y;
public:
#ifdef SWIG
    Foo<T>(T x) : y(x) { }
#else
    // Modern compilers reject this, so feed the compiler the corrected
    // version.
    Foo(T x) : y(x) { }
#endif
};

%}

%template(Foo_int) Foo<int>;
