%module using_private

%inline %{
class Foo {
public:
     int x;
     int blah(int x) { return x; }
};

class FooBar : private Foo {
public:
     using Foo::blah;
     using Foo::x;
};

%}

