%module using_protected

%inline %{
class Foo {
protected:
     int x;
     int blah(int xx) { return xx; }
};

class FooBar : public Foo {
public:
     using Foo::blah;
     using Foo::x;
};

%}

