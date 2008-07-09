#include <stdio.h>

#include "c_arguments/c_arguments_proxy.h"

int main(int argc, char **argv) {
  A* a = new_A();
  if (A_foo(a, 0) != 1)
    fprintf(stderr, "call to A_foo() failed\n");
  delete_A(a);

  int ***array = (int ***) 0;

  foo_1(array);

  return 0;
}

