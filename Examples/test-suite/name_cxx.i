/* This interface files tests whether SWIG handles overloaded
   renamed functions and inheriting from a renamed class.
*/

%module name_cxx

%rename bar(int) "bar_int";
%rename bar(double) "bar_double";
%rename A "AA";

%inline %{
void bar(int i) {}
void bar(double i) {}

// %rename inheritance test
class A {
};

class B : public A {
};

%}
