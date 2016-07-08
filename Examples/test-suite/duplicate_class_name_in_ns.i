%module a;

namespace A
{
    class Foo {
    public:
        Foo(){};
    };
}

namespace B
{
    template<typename T, typename U>
        class Foo : public A::Foo {
    public:
        Foo(){};
        int foo();
    };
    
    %template(B) Foo<int, double>;
}
