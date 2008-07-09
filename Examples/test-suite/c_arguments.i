%module c_arguments

%inline %{

class A {
  public:
    A() {}
    int foo(int i) {
      return i+1;
    }
};

void foo(A a, A &ra, A *pa, char c, char *str, char **pstr, char ***ppstri) {
}

void foo_1(int ***a) {

}

%}
