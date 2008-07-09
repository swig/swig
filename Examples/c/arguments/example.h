#include <stdio.h>

class A {
public:
  int i;
  A(int i) : i(i) {}
  void foo() {
  }
};

class B : public A {
public:
  B(int i) : A(i) {}
};

class MyClass {
public:
  void foo(A a, A* aa, A* aaa[5]) {
    printf("a.i = %d\n", a.i);
    printf("aa->i = %d\n", aa->i);
    int i = 0;
    while (aaa[i]) {
      printf("aaa[%d]->i = %d\n", i, aaa[i]->i);
      i++;
    }
  }

  void bar(int x, int* px, int** xs) {
    printf("x = %d\n", x);
    printf("*px = %d\n", *px);
    int i = 0;
    while (xs[i]) {
      printf("*xs[%d] = %d\n", i, *xs[i]);
      i++;
    }
  }

  void foo_1(A& a, A& b) {
    printf("a.i = %d\n", a.i);
    printf("b.i = %d\n", b.i);
    a.i++;
    b.i++;
  }

  void foo_2(int& x, double& d) {
    printf("x = %d d = %f\n", x, d);
    x++;
    d++;
  }

};

