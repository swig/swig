// Here's a nice little test for renaming, symbol table management, and default arguments

%module rename_default

// Rename a class member
%rename(bar2) Foo::bar;

%inline %{

// Define a class
class Foo {
public:
    static int bar;
    static int spam;

    // Use a renamed member as a default argument.  SWIG has to resolve
    // bar to Foo::bar and not Foo::spam.  SWIG-1.3.11 got this wrong.

    void method1(int x = bar) {}
   
    // Use unrenamed member as default
    void method2(int x = spam) {}
};
int Foo::bar = 1;
int Foo::spam = 2;
%}

