#include "typedef_funcptr/typedef_funcptr_wrap.h"
#include <assert.h>
#include <string.h>

using namespace typedef_funcptr;

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

  assert(do_op(a, b, add) == 110);
  assert(do_op(a, b, subtract) == 90);
  assert(do_op_typedef_int(a, b, add) == 110);
  assert(do_op_typedef_int(a, b, subtract) == 90);
  assert(do_op_typedef_Integer(a, b, add) == 110);
  assert(do_op_typedef_Integer(a, b, subtract) == 90);

  assert(get_op_typedef_int(0)(a, b) == 110);
  assert(get_op(1)(a, b) == 90);

  assert(strcmp(do_name(2, number_name), "two") == 0);
  assert(strcmp(do_name_typedef(2, number_name), "two") == 0);
  const char *(*namer)(int) = get_name_op();
  assert(strcmp(namer(1), "one") == 0);

  OpHolder holder;
  const OpHolder &const_holder = holder;
  assert(const_holder.get_member_op()(a, b) == 110);
  assert(holder.get_static_op()(a, b) == 90);
  assert(const_holder.get_const_member_op()(a, b) == 110);
  holder.member_fn(subtract);
  assert(const_holder.member_fn()(a, b) == 90);
  OpHolder::static_fn(add);
  assert(OpHolder::static_fn()(a, b) == 110);
  namer = const_holder.name_fn();
  assert(strcmp(namer(1), "one") == 0);
  holder.name_fn(number_name);
  namer = const_holder.name_fn();
  assert(strcmp(namer(2), "two") == 0);

  assert(do_op_const_ref(a, b, add) == 110);

  assert(do_op_const(a, b, add) == 110);
  assert(do_op_typedef_const(a, b, subtract) == 90);
  assert(get_const_op(1)(a, b) == 90);
  return 0;
}
