%module extend_placement

// Tests placement of %extend directives

// Before the class

%extend Foo {
    Foo(int a) { return new Foo(); }
    ~Foo() { delete self;}
    int spam(int x) { return x; }
};

%inline %{
class Foo {
public:
  Foo(){}

  int spam() { return 1; }
  int spam(const char* c) { return 2; }
};
%}

// After the class

%inline %{
class Bar {
public:
 int spam() { return 1; }
 int spam(const char* c) { return 2; }
};
%}


%extend Bar {
    Bar() { return new Bar(); }
    ~Bar() { delete self;}
    //    int spam(int x) { return x; }
};
