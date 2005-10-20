%module import_nomodule
%{
#include "import_nomodule.h"
%}

%import "import_nomodule.h"

#if !defined(SWIGJAVA) && !defined(SWIGRUBY) && !defined(SWIGCSHARP)

/**
 * The proxy class does not have Bar derived from Foo, yet an instance of Bar
 * can successfully be passed to a proxy function taking a Foo pointer (for some
 * language modules).
 * 
 * This violation of the type system is not possible in Java and C# due to static
 * type checking. It's also not (currently) possible in Ruby, but this may be
 * fixable (needs more investigation).
 */

%newobject create_Foo;
%inline %{
Foo *create_Foo() {
   return new Foo();
}

void test1(Foo *f, Integer x) { }

class Bar : public Foo { };

%}

#endif

