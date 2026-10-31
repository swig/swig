#include "funcptr_cpp/funcptr_cpp_wrap.h"
#include <assert.h>

using namespace funcptr_cpp;

static int add_by_value(const int &a, int b) {
  return a + b;
}

static int &add_by_reference(const int &a, int b) {
  static int val;
  val = a + b;
  return val;
}

static bool not_bool(bool b) {
  return !b;
}

int main(int argc, const char *argv[]) {
  assert(call1(add_by_value, 10, 11) == 21);
  assert(call3(add_by_reference, 14, 15) == 29);
  assert(callconst1(add_by_value, 2, 3) == 5);
  assert(callptrref2(add_by_value, 5, 6) == 11);

  AddByValueGetter getter;
  assert(call1(getter.getPtr(), 7, 8) == 15);
  assert(callBoolFn(not_bool, 0) == 1);
  return 0;
}
