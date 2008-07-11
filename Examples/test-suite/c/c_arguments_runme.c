#include <stdio.h>

#include "c_arguments/c_arguments_proxy.h"

int main(int argc, char **argv) {
  A *a = new_A();

  A *a1, *a2, *a3;

  a1 = foo_1(a);
  a2 = foo_2(a);
  a3 = foo_3(a);

  delete_A(a);
  delete_A(a1);
  delete_A(a2);
  delete_A(a3);
  return 0;
}

