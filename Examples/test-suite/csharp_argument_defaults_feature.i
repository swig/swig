%module csharp_argument_defaults_feature
%include "std_string.i"


%feature("cs:defaultargs") Foo::Foo;
%feature("cs:defaultargs", z=4) Foo::bar;
%feature("cs:defaultargs", x="\"fives\"") Foo::zoo;
%feature("cs:defaultargs", value="System.Math.PI") Foo::pi;

//intentionally don't touch bat, leave it to normal handling

%inline %{
#include <string>
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
    int zoo(std::string x="four")
    {
        return (int)x.size();
    }
    double pi(double value=3.14)
    {
        return value;
    }
};
%}



