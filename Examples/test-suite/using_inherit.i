%module using_inherit

%inline %{

class Foo {
public:
     int test(int x) { return x; }
     double test(double x) { return x; };
};

class Bar : public Foo {
public:
     using Foo::test;
};

%}

