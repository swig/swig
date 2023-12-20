%module csharp_argument_defaults_feature
%include "std_string.i"
%include <swiginterface.i>

%feature("cs:defaultargs") Foo::Foo;
%feature("cs:defaultargs", z=4) Foo::bar;
%feature("cs:defaultargs", x="\"fives\"") Foo::zoo;
%feature("cs:defaultargs", value="System.Math.PI") Foo::pi;
%feature("cs:defaultargs", s=R"--("fives")--") Foo::lengthOfString;
%feature("cs:defaultargs", z=4) ::gbar;
%feature("cs:defaultargs", z=4) Foo::sbar;
%feature("cs:defaultargs", z=4) AnInterface::foo;
%interface(AnInterface)

//intentionally don't touch bat, leave it to normal handling

%inline %{
#include <string>

enum EnumerationType {
    one=1,
    two,
    three
};

int gbar(int x, int y=2, int z=3)
{
    return x+y+z;
}
int gbat(int x=1, int y=2, int z=3)
{
    return x+y+z;
}

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
    int lengthOfString(const std::string& s="four")
    {
        return (int)s.size();
    }
    int valueofenum(EnumerationType t=two)
    {
        return (int)t;
    }
    int valueofchar(char c='c')
    {
        return (int)c;
    }

    static int sbar(int x, int y=2, int z=3)
    {
        return x+y+z;
    }
    static int sbat(int x=1, int y=2, int z=3)
    {
        return x+y+z;
    }
};

class AnInterface
{
public:
    AnInterface() {}
    virtual int foo(int x=1, int y=2, int z=3) = 0;
    virtual ~AnInterface() {}
};

class AnImplementation: public AnInterface
{
public:
    int foo(int x=1, int y=2, int z=3)
    {
        return x*y+z;
    }
};
%}



