%module using_private

%inline %{
class Foo {
public:
     int x;
     int blah(int x) { return x; }
     int defaulted(int i = -1) { return i; }
};

class FooBar : private Foo {
public:
     using Foo::blah;
     using Foo::x;
     using Foo::defaulted;
};

%}

