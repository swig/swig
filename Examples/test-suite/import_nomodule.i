%module import_nomodule
%{
#include "import_nomodule.h"
%}

%import "import_nomodule.h"

#ifndef SWIGJAVA
// The proxy class does not have Bar derived from Foo, yet an instance of Bar can successfully be passed to a proxy function taking a Foo pointer. 
// This violation of the type system is not possible in Java due to its static type checking.
%inline %{
Foo *create_Foo() {
   return new Foo();
}

void test1(Foo *f, Integer x) { };

class Bar : public Foo { };

%}
#endif



