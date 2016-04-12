#include <stdio.h>

#include "example_wrap.h"

int main(int argc, char **argv) {
  int a = 42;
  int b = 105;
  int g = _wrap_gcd(a, b);
  printf("The gcd of %d and %d is %d\n", a, b, g);
  printf("Foo = %f\n", Foo);
  Foo = 3.1415926;
  printf("Foo = %f\n", Foo);
  SWIG_exit(0);
}

