/* This interface file tests whether SWIG/Guile handle the %rename and
   %name directives, which was not the case in 1.3a5.
*/

%rename foo_1 "foo-2";
%inline %{
void foo_1() {}
%}

%name("bar-2")
%inline %{
int bar_1 = 17;
%}

%constant(int) baz_1 = 47;
