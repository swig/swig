/* This interface files tests whether SWIG handles overloaded
   renamed functions. 
*/

%module test

%name("bar_int")
%inline %{
void bar(int i) {}
%}

%name("bar_double")
%inline %{
void bar(double i) {}
%}

