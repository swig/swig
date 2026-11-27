#include "funcptr_cpp/funcptr_cpp_wrap.h"
#include <assert.h>

static int add_by_value(const int *a, int b) {
  return *a + b;
}

static int *add_by_pointer(const int *a, int b) {
  static int val;
  val = *a + b;
  return &val;
}

static int not_wrapped_value_plus_one(SWIGTYPE_p_NotWrapped *p) {
  return funcptr_cpp_notWrappedValue(p) + 1;
}

static bool not_bool(bool b) {
  return !b;
}

int main(int argc, const char *argv[]) {
  int (*fn)(const int *, int) = add_by_value;
  int array[4] = {1, 2, 3, 4};

  assert(funcptr_cpp_call1(add_by_value, 10, 11) == 21);
  assert(funcptr_cpp_call2(add_by_pointer, 12, 13) == 25);
  assert(funcptr_cpp_call3(add_by_pointer, 14, 15) == 29);
  assert(funcptr_cpp_callref1(add_by_value, 1, 2) == 3);
  assert(funcptr_cpp_callref2(funcptr_cpp_getAddByValueRef1(), 3, 4) == 7);
  assert(funcptr_cpp_callptrref1(&fn, 9, 10) == 19);
  assert(funcptr_cpp_callptrref2(fn, 5, 6) == 11);
  assert((*funcptr_cpp_getAddByValuePtrRef())(&array[0], 2) == 3);

  assert(funcptr_cpp_arrayRefSum(funcptr_cpp_getArrayRef1()) == 100);
  assert(funcptr_cpp_arrayRefSum(&array) == 10);
  assert((*funcptr_cpp_getArrayRef2())[3] == 40);

  assert(funcptr_cpp_callNotWrappedFn(not_wrapped_value_plus_one, funcptr_cpp_getNotWrapped()) == 43);
  assert(funcptr_cpp_callBoolFn(not_bool, 0) == 1);
  return 0;
}
