#include "typedef_funcptr/typedef_funcptr_wrap.h"
#include <assert.h>

using namespace typedef_funcptr;

static int add(int x, int y) {
  return x + y;
}

static int subtract(int x, int y) {
  return x - y;
}

int main(int argc, const char *argv[]) {
  int a = 100;
  int b = 10;

  assert(do_op(a, b, add) == 110);
  assert(do_op(a, b, subtract) == 90);
  assert(do_op_typedef_int(a, b, add) == 110);
  assert(do_op_typedef_int(a, b, subtract) == 90);
  assert(do_op_typedef_Integer(a, b, add) == 110);
  assert(do_op_typedef_Integer(a, b, subtract) == 90);

  assert(get_op_typedef_int(0)(a, b) == 110);
  assert(get_op(1)(a, b) == 90);

  OpHolder holder;
  const OpHolder &const_holder = holder;
  assert(const_holder.get_member_op()(a, b) == 110);
  assert(holder.get_static_op()(a, b) == 90);
  holder.member_fn(subtract);
  assert(const_holder.member_fn()(a, b) == 90);
  OpHolder::static_fn(add);
  assert(OpHolder::static_fn()(a, b) == 110);
  return 0;
}
