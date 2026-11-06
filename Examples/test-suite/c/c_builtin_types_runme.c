#include "c_builtin_types/c_builtin_types_wrap.h"
#include <assert.h>

int main() {
  unsigned int uints[2] = {5, 6};
  long long long_longs[2] = {7, 8};
  unsigned short ushorts[2] = {9, 10};
  unsigned int value = 12;
  unsigned int *p = &value;
  unsigned int **pp = &p;
  const int grid[2][3] = {{1, 2, 3}, {4, 5, 6}};
  BuiltinArrays *arrays = BuiltinArrays_new();

  assert(!bool_flag);
  bool_flag = true;
  assert(bool_flag);

  assert(unsigned_count == 1);
  unsigned_count = 3;
  assert(unsigned_count == 3);
  assert(long_long_count == 2);

  BuiltinArrays_uints_set(arrays, uints);
  assert(BuiltinArrays_uints_get(arrays)[0] == 5);
  assert(BuiltinArrays_uints_get(arrays)[1] == 6);
  BuiltinArrays_long_longs_set(arrays, long_longs);
  assert(BuiltinArrays_long_longs_get(arrays)[0] == 7);
  assert(BuiltinArrays_long_longs_get(arrays)[1] == 8);
  assert(BuiltinArrays_uints_get(arrays)[1] == 6);

  assert(BuiltinArrays_ushorts_get()[1] == 4);
  BuiltinArrays_ushorts_set(ushorts);
  assert(BuiltinArrays_ushorts_get()[0] == 9);
  assert(BuiltinArrays_ushorts_get()[1] == 10);

  assert(c_builtin_types_unsigned_pointer_value(&pp) == 12);
  /* The .h file declares the parameter as 'const int **' */
  assert(c_builtin_types_const_grid_value((const int **)grid) == 6);

  BuiltinArrays_delete(arrays);
  return 0;
}
