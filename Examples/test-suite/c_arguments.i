%module c_arguments

%inline %{

class A {
  public:
    A() : i(0) {}
    int i;
};

A foo_1(A *a) {
  return *a;
}

A * foo_2(A *a) {
  return a;
}

A & foo_3(A *a) {
  return *a;
}

%}
