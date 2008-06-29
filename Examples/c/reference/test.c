#include <stdio.h>

#include "example_proxy.h"

void test(Bar * bar) {
  printf("value of x is %d\n", Bar_get(bar));
}

int main(int argc, char** argv) {
  Bar * bar = new_Bar();
  test(bar);
  foo_by_val(bar);
  test(bar);
  foo_by_ptr(bar);
  test(bar);
  foo_by_ref(bar);
  test(bar);
  delete_Bar(bar);
  return 0;
}

