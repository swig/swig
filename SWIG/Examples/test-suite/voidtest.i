%module voidtest

%inline %{

void globalfunc(void) {
}

class Foo {
public:
   Foo() { }
   void memberfunc(void) { }
   static void staticmemberfunc(void) { }
};

%}
   
