// This file tests SWIG's tracking of C++ typedef declarations

%module cpp_typedef

%{

class Bar {
public:
};
%}

%inline %{
class Foo {
public:
    typedef Bar SomeBar;
    typedef SomeBar SomeOtherBar;
    SomeOtherBar bar() {
        SomeOtherBar b;
        return b;
    }
    static SomeOtherBar sbar() {
        SomeOtherBar b;
        return b;
    }
};
%}
        

