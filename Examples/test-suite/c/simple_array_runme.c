#include <stdio.h>
#include <stdlib.h>

#include "simple_array/simple_array_wrap.h"

static void check(int ok, const char *test) {
  if (!ok) {
    fprintf(stderr, "Test %s failed\n", test);
    exit(1);
  }
}

int main() {
  simple_array_initArray();
  check(x[3] == 3, "x");
  check(bars[1].i == 3, "bars");

  /* The two dimensional array is declared with the size of its second dimension */
  xy[1][2] = 5;
  check(xy[1][2] == 5 && xy[0][2] == 0, "xy");

  check(bool_flag, "bool_flag");
  bool_flag = false;
  check(!bool_flag, "bool_flag set");

  return 0;
}
