/* This interface file tests whether SWIG's extended C
   preprocessor is working right. 

   In this example, SWIG 1.3a5 reports missing macro arguments, which
   is bogus.
*/

%define FOO(C_TYPE, GETLENGTH)
     /* nothing */
%enddef

%define BAR(XYZZY)
  FOO(XYZZY, 1)
%enddef

BAR(int)

%module macro_2

%inline %{
  int dummy_var;
%}
