#include <stdio.h>
#include <stdlib.h>

#include "c_namespace_globals/c_namespace_globals_wrap.h"

int main() {
  ns_counter_set(42);
  if (ns_counter_get() != 42) {
    fprintf(stderr, "counter failed\n");
    exit(1);
  }

  if (ns_limit_get() != 5) {
    fprintf(stderr, "limit failed\n");
    exit(1);
  }

  if (ns_const_result(7) != 7) {
    fprintf(stderr, "const_result failed\n");
    exit(1);
  }

  return 0;
}
