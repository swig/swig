%module a;

%inline {

namespace A
{
    template<typename T>
    class Foo
    {
    public:
        Foo(){};
    };

    %template(A) Foo<double>;

    class Bar
    {
    public:
        Bar(){};
    };
}

namespace B
{
    template<typename T, typename U>
    class Foo : public A::Foo<U>
    {
    public:
        Foo(){};
        A::Foo<U> do_foo();
    };

    %template(B) Foo<int, double>;

    template<typename T, typename U>
    class Bar : public A::Bar {
    public:
        Bar(){};
        A::Bar do_bar();
    };
}

}
