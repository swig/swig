#include <stdio.h>
#include <stdlib.h>

#include "ret_by_value/ret_by_value_wrap.h"

static void check(int ok, const char *test) {
  if (!ok) {
    fprintf(stderr, "Test %s failed\n", test);
    exit(1);
  }
}

int main() {
  test t = ret_by_value_get_test();

  check(t.myInt == 100, "get_test myInt");
  check(t.myShort == 200, "get_test myShort");
  check(ret_by_value_get_my_int(t) == 100, "get_my_int");

  return 0;
}
