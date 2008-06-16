#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char **argv) {
  int a = 35;
  int b = 15;
  printf("Foo is %f\n", Foo);
  printf("Foo by ptr is \%f (%d)\n", *Foo_ptr, (int) Foo_ptr);
  printf("my_str is: %s\n", my_str);
  printf("array_of_strs contains %s and %s\n", get_str(0), get_str(1));
  printf("GCD(%d, %d)=%d\n", a, b, gcd(a, b));
  return 0;
}

