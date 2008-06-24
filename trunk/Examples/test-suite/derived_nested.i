/* This testcase tests nested derived classes.
This was reported in bug #909389 */

%module derived_nested

%inline %{

class A { int x; };
class B {
  class C { int y; }; //generates a warning
  class D : public A { int z; }; //ok
};

%}

