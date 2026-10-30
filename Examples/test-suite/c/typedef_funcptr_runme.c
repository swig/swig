#include "typedef_funcptr/typedef_funcptr_wrap.h"
#include <assert.h>
#include <string.h>

static int add(int x, int y) {
  return x + y;
}

static int subtract(int x, int y) {
  return x - y;
}

static const char *number_name(int i) {
  return i == 2 ? "two" : "other";
}

int main(int argc, const char *argv[]) {
  int a = 100;
  int b = 10;

  assert(typedef_funcptr_do_op(a, b, add) == 110);
  assert(typedef_funcptr_do_op(a, b, subtract) == 90);
  assert(typedef_funcptr_do_op_typedef_int(a, b, add) == 110);
  assert(typedef_funcptr_do_op_typedef_int(a, b, subtract) == 90);
  assert(typedef_funcptr_do_op_typedef_Integer(a, b, add) == 110);
  assert(typedef_funcptr_do_op_typedef_Integer(a, b, subtract) == 90);

  assert(typedef_funcptr_get_op_typedef_int(0)(a, b) == 110);
  assert(typedef_funcptr_get_op(1)(a, b) == 90);

  assert(strcmp(typedef_funcptr_do_name(2, number_name), "two") == 0);
  assert(strcmp(typedef_funcptr_do_name_typedef(2, number_name), "two") == 0);
  const char *(*namer)(int) = typedef_funcptr_get_name_op();
  assert(strcmp(namer(1), "one") == 0);

  typedef_funcptr_OpHolder *holder = typedef_funcptr_OpHolder_new();
  assert(typedef_funcptr_OpHolder_get_member_op(holder)(a, b) == 110);
  assert(typedef_funcptr_OpHolder_get_static_op(holder)(a, b) == 90);
  typedef_funcptr_OpHolder_member_fn_set(holder, subtract);
  assert(typedef_funcptr_OpHolder_member_fn_get(holder)(a, b) == 90);
  typedef_funcptr_OpHolder_static_fn_set(add);
  assert(typedef_funcptr_OpHolder_static_fn_get()(a, b) == 110);
  namer = typedef_funcptr_OpHolder_name_fn_get(holder);
  assert(strcmp(namer(1), "one") == 0);
  typedef_funcptr_OpHolder_name_fn_set(holder, number_name);
  namer = typedef_funcptr_OpHolder_name_fn_get(holder);
  assert(strcmp(namer(2), "two") == 0);
  typedef_funcptr_OpHolder_delete(holder);
  return 0;
}
