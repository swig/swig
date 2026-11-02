#include "li_std_vector/li_std_vector_wrap.h"
#include <assert.h>

using namespace li_std_vector;

int main() {
  int values[2] = {1, 2};
  const int *cp = &values[1];

  // A const reference to a pointer to a builtin type is passed and returned as the pointer
  IntPtrVector ipv;
  ipv.push_back(&values[0]);
  assert(ipv.get(0) == &values[0]);
  ipv.set(0, &values[1]);
  assert(*ipv.get(0) == 2);

  IntConstPtrVector icpv;
  icpv.push_back(cp);
  assert(icpv.get(0) == cp);
  assert(*icpv.get(0) == 2);
  return 0;
}
