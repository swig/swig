%module com_opaque_types

/*
 * Opaque types have their unique IIDs. This allows to test whether
 * they work correctly.
 */

%ignore A;
%ignore B;

%inline %{

class A {
  public:
  int id() { return 1884; }
};

class B {
  public:
  int id() { return 2005; }
};

int test(A *arg) {
  return arg->id();
}

A* fact_A() {
  return new A;
}

B* fact_B() {
  return new B;
}

%}
