#include "funcptr/funcptr_wrap.h"
#include <assert.h>

static int multiply_add_one(int a, int b) {
  return a * b + 1;
}

static int bool_inverse(bool b) {
  return b ? 0 : 1;
}

int main() {
  assert(funcptr_do_op(1, 3, funcptr_add) == 4);
  assert(funcptr_do_op(2, 3, funcptr_multiply) == 6);
  assert(funcptr_do_op(2, 3, funcvar) == 5);

  /* C functions */
  assert(funcptr_do_op(2, 3, multiply_add_one) == 7);

  /* A function pointer using bool */
  assert(funcptr_call_funcvarbool(1) == 1);
  assert(funcptr_call_funcvarbool(0) == 0);
  funcvarbool = bool_inverse;
  assert(funcptr_call_funcvarbool(1) == 0);
  assert(funcptr_call_funcvarbool(0) == 1);

  return 0;
}
