%module csharp_argument_defaults_feature



%feature("cs:argdef") Foo::Foo "*:$value"
%feature("cs:argdef") Foo::bar "*:$value,z:4"

//intentionally don't touch bat, leave it to normal handling

%inline %{
class Foo {
public:
    virtual ~Foo() {}
    Foo(int a, int b=1, int c=2)
    {
    }
    int bar(int x, int y=2, int z=3)
    {
        return x+y+z;
    }
    int bat(int x=1, int y=2, int z=3)
    {
        return x+y+z;
    }
};
%}



