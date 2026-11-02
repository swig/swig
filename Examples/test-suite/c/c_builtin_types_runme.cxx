#include "c_builtin_types/c_builtin_types_wrap.h"
#include <assert.h>

int main() {
  unsigned int uints[2] = {5, 6};
  long long long_longs[2] = {7, 8};
  c_builtin_types::BuiltinArrays arrays;

  arrays.uints(uints);
  assert(arrays.uints()[1] == 6);
  arrays.long_longs(long_longs);
  assert(arrays.long_longs()[1] == 8);
  assert(arrays.uints()[1] == 6);
  assert(c_builtin_types::BuiltinArrays::ushorts()[1] == 4);
  return 0;
}
