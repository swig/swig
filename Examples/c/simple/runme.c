#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char **argv) {
  int a = 35;
  int b = 15;
  printf("Foo is %f\n", Foo);
  printf("Foo by ptr is \%f\n", *Foo_ptr);
  printf("my_str is: %s\n", my_str);
  printf("GCD(%d, %d)=%d\n", a, b, gcd(a, b));
  printf("array_of_strs contains %s and %s\n", get_str(0, 0, 0), get_str(1, 0, 0));
  return 0;
}

