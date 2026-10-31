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

  check(strcmp(names[1], "one") == 0, "names_get");
  check(strcmp(namer(1), "one") == 0, "namer_get");

  return 0;
}
