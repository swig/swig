%module duplicate_class_name_in_ns

%rename(XA) A::X;
%rename(XB) B::X;

%inline %{

namespace A
{
    class X
    {
    public:
        X(){};
    };

    template<typename T>
    class Foo
    {
    public:
        Foo(){};
    };

    class Bar
    {
    public:
        Bar(){};
    };

    template<typename T>
    class Baz
    {
    public:
        Baz(){};
    };
}

namespace B
{
    // non-template derived from non-template
    class X : public A::X
    {
    public:
        X(){};
        A::X do_x(){return A::X();}
    };

    // template derived from template with different template args
    template<typename T, typename U>
    class Foo : public A::Foo<U>
    {
    public:
        Foo(){};
        A::Foo<U> do_foo(){return A::Foo<U>();}
    };

    // template derived from non-template
    template<typename T, typename U>
    class Bar : public A::Bar
    {
    public:
        Bar(){};
        A::Bar do_bar(){return A::Bar();}
    };

    // template derived from template with same template args
    template<typename T>
    class Baz : public A::Baz<T>
    {
    public:
        Baz(){};
        A::Baz<T> do_baz(){return A::Baz<T>();}
    };
}

%}

%template(AFoo) A::Foo<double>;
%template(ABaz) A::Baz<double>;
%template(BFoo) B::Foo<int, double>;
%template(BBar) B::Bar<int, double>;
%template(BBaz) B::Baz<double>;

%inline %{
    A::X get_a_x() {B::X x; return x.do_x();}
    A::Foo<double> get_a_foo() {B::Foo<int, double> x; return x.do_foo();}
    A::Bar get_a_bar() {B::Bar<int, double> x; return x.do_bar();}
    A::Baz<double> get_a_baz() {B::Baz<double> x; return x.do_baz();}
%}
