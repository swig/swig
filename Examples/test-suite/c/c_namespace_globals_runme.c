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

  {
    int values[3] = {4, 5, 6};
    ns_numbers_set(values);
    if (ns_numbers_get()[2] != 6) {
      fprintf(stderr, "numbers failed\n");
      exit(1);
    }
  }

  if (ns_primes_get()[1] != 3) {
    fprintf(stderr, "primes failed\n");
    exit(1);
  }

  if (ns_operation_get()(1, 2) != 3) {
    fprintf(stderr, "operation failed\n");
    exit(1);
  }

  if (ns_get_operation()(3, 4) != 7) {
    fprintf(stderr, "get_operation failed\n");
    exit(1);
  }

  return 0;
}
