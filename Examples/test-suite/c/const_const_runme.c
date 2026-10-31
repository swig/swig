#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "const_const/const_const_wrap.h"

static void check(int ok, const char *test) {
  if (!ok) {
    fprintf(stderr, "Test %s failed\n", test);
    exit(1);
  }
}

int main() {
  const char **names = const_const_names_get();
  const char *(*namer)(int) = const_const_namer_get();
  const struct Point point = {3};
  const enum Colour green = GREEN;
  const enum Colour *colour = &green;

  check(strcmp(names[1], "one") == 0, "names_get");
  check(strcmp(namer(1), "one") == 0, "namer_get");
  check(const_const_point_x(&point) == 3, "point_x");
  check(const_const_colour_value(&colour) == GREEN, "colour_value");

  return 0;
}
