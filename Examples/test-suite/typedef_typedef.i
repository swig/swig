%module typedef_typedef

/*

 We want a specific behaviour on a Type

*/

%typemap(out) A::Foo {
    $result = PyInt_FromLong($1 + 1);
}

%inline %{
    struct A
    {
         typedef int Foo;
    };

    struct C
    {
         typedef A Bar;
    };

    struct B
    {
         C::Bar::Foo getValue() {
             return 0;
         }
    };
%}

/*

  An issue can be the steps resolution.
  1) C::Bar is A. So C::Bar::Foo should be first resolved as A::Foo.
  2) Then A::Foo should be resolved int.
  If the first step is skipped the typemap is not applied.

*/
