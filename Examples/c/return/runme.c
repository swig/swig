#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char** argv) {
  Bar b = foo_ret_val();
  //Bar * bp = foo_ret_ptr(NULL);
  printf("x = %d\n", Bar_get(&b));
  return 0;
}

