// Tests copy constructor
%module overload_copy

%inline %{

class Foo {
public:
    Foo() { }
    Foo(const Foo &) { }
};

%}
