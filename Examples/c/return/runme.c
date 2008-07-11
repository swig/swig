#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char** argv) {
  Bar *b = foo_ret_val();
  printf("x = %d\n", Bar_get(b));
  Bar *bp = foo_ret_ptr(NULL);
  Bar *br = foo_ret_ref(new_Bar());

  delete_Bar(b);
  delete_Bar(br);
  return 0;
}

