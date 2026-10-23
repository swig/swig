%module constructor_rename

%{
struct Foo {
    Foo() {}
    int answer() const { return 42; }
};
%}

struct Foo {
    %rename(RenamedConstructor) Foo();
    Foo() {}
    int answer() const { return 42; }
};
