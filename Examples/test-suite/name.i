/* This interface file tests whether SWIG/Guile handle the %rename and
   %name directives, which was not the case in 1.3a5.
*/

%module name

#pragma SWIG nowarn=121 // %name is deprecated. Use %rename instead.

#ifdef SWIGGUILE
%rename foo_1 "foo-2";
#else
%rename foo_1 "foo_2";
#endif
%inline %{
void foo_1() {}
%}

#ifdef SWIGGUILE
%name("bar-2")
#else
%name("bar_2")
#endif
%inline %{
int bar_1 = 17;
%}

%name("Baz_2")
%constant int Baz_1 = 47;
