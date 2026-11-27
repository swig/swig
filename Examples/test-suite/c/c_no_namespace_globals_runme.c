#include "c_no_namespace_globals/c_no_namespace_globals_wrap.h"
#include <assert.h>

static int thrice(int i) {
  return 3 * i;
}

int main(int argc, const char *argv[]) {
  number_set(5);
  assert(number_get() == 5);

  assert(operation_get()(4) == 8);
  operation_set(thrice);
  assert(operation_get()(4) == 12);

  assert(Counter_count_get(counter_get()) == 0);
  return 0;
}
