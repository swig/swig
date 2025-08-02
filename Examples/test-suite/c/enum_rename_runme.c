#include <assert.h>

#include "enum_rename/enum_rename_wrap.h"

int main() {
  assert(enum_rename_M_Jan == 0);
  assert(enum_rename_May   == 1);
  assert(enum_rename_M_Dec == 2);

  assert(enum_rename_S_Can  == 1);
  assert(enum_rename_S_Must == 2);
}
