/* This interface file tests whether SWIG/Guile handle the %rename
   directive, which was not the case in 1.3a5.
*/

%module name

#ifdef SWIGGUILE
%rename foo_1 "foo-2";
%rename bar_1 "bar-2";
#else
%rename foo_1 "foo_2";
%rename bar_1 "bar_2";
#endif
%rename Baz_1 "Baz_2";

%inline %{
void foo_1() {}
int bar_1 = 17;
%}

%constant int Baz_1 = 47;
