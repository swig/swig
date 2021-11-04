#include <assert.h>

#include "enum_rename/enum_rename_wrap.h"

int main() {
  assert(M_Jan == 0);
  assert(May   == 1);
  assert(M_Dec == 2);

  assert(S_Can  == 1);
  assert(S_Must == 2);
}
