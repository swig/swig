#include <stdio.h>

class A {
public:
  int i;
  A(int i) : i(i) {}
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

  void bar(int x, int* px, int* xs[5]) {
    printf("x = %d\n", x);
    printf("*px = %d\n", *px);
    int i = 0;
    while (xs[i]) {
      printf("*xs[%d] = %d\n", i, *xs[i]);
      i++;
    }
  }

};

