#include <stdio.h>
#include <stdlib.h>

#include "c99_vla_typemaps/c99_vla_typemaps_wrap.h"

int main() {
  int middle[2] = {1, 2};
  int end[2] = {3, 4};

  /* The 'in' typemaps are not used when wrapping C, so every argument is passed */
  if (c99_vla_typemaps_ignored_arguments(5, 2, middle, 10, end) != 42) {
    fprintf(stderr, "ignored_arguments failed\n");
    exit(1);
  }

  return 0;
}
