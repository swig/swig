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

static int point_x_plus_one(typedef_funcptr_Point *p) {
  return typedef_funcptr_Point_x_get(p) + 1;
}

static enum typedef_funcptr_Shade darken(enum typedef_funcptr_Shade s) {
  return s == typedef_funcptr_Light ? typedef_funcptr_Dark : s;
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
  assert(typedef_funcptr_OpHolder_get_const_member_op(holder)(a, b) == 110);
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

  int (*op)(int, int) = 0;
  typedef_funcptr_set_op_ref(&op, 1);
  assert(op(a, b) == 90);
  typedef_funcptr_set_op_ptr(&op, 0);
  assert(op(a, b) == 110);
  assert(typedef_funcptr_do_op_ref(a, b, &op) == 110);
  assert(typedef_funcptr_do_op_const_ref(a, b, op) == 110);
  assert((*typedef_funcptr_get_op_ref())(a, b) == 110);
  *typedef_funcptr_get_op_ref() = subtract;
  assert((*typedef_funcptr_get_op_ref())(a, b) == 90);

  assert(typedef_funcptr_do_op_const(a, b, add) == 110);
  assert(typedef_funcptr_do_op_typedef_const(a, b, subtract) == 90);
  assert(typedef_funcptr_get_const_op(1)(a, b) == 90);

  typedef_funcptr_Point *point = typedef_funcptr_Point_new();
  typedef_funcptr_Point_x_set(point, 5);
  assert(typedef_funcptr_do_point(point, point_x_plus_one) == 6);
  assert(typedef_funcptr_get_point_getter()(point) == 5);
  typedef_funcptr_Point_delete(point);
  assert(typedef_funcptr_do_shade(typedef_funcptr_Light, darken) == typedef_funcptr_Dark);
  assert(typedef_funcptr_get_shader()(typedef_funcptr_Dark) == typedef_funcptr_Light);
  return 0;
}
