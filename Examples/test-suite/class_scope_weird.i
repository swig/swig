%module class_scope_weird

%inline %{
class Foo {
public:
    int Foo::bar(int x) {
       return x;
    }
};
%}

