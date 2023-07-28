%module copyctor

%copyctor;

%inline %{
struct Bar {};
struct Car {};

struct Foo {
    Foo() {}
    template <class T> Foo(const T* p) {}
    Foo(const Bar& other) {}
};

struct Hoo {
    Hoo() {}
    template <class T> Hoo(const T* p) {}
    Hoo(const Bar& other) {}
};
%}

%template(Hoo) Hoo::Hoo<Car>;
