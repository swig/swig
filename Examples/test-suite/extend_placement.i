%module extend_placement

// Tests placement of %extend directives

// Before the class

%extend Foo {
    Foo() { return new Foo(); }
    ~Foo() { delete self;}
    int spam(int x) { return x; }
};

%inline %{
class Foo { };
%}

// After the class

%inline %{
class Bar { };
%}


%extend Bar {
    Bar() { return new Bar(); }
    ~Bar() { delete self;}
    int spam(int x) { return x; }
};
