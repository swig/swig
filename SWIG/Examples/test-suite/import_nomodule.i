%module import_nomodule
%{
#include "import_nomodule.h"
%}

%import "import_nomodule.h"

%inline %{
Foo *create_Foo() {
   return new Foo();
}

void test1(Foo *f, Integer x) { };

class Bar : public Foo { };

%}




