%module constructor_explicit
%inline %{

class Foo {
public:
   explicit Foo() { }
};

Foo test(Foo x) {
   return x;
}

%}
