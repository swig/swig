#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char** argv) {
  Bar *b = foo_ret_val();
  printf("x = %d\n", Bar_get(b));

  Bar *c = new_Bar();
  Bar *bp = foo_ret_ptr(c);
  //Bar *br = foo_ret_ref(c);

  delete_Bar(b);
  delete_Bar(bp);
  delete_Bar(c);
  return 0;
}

