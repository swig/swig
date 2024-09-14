#include <assert.h>
#include <stdlib.h>

#include "enums/enums_wrap.h"

int main() {
  assert(GlobalInstance == globalinstance1);
  assert(iFoo_Char == 'a');
  enums_bar2(1);
  enums_bar3(1);
  enums_bar1(1);
  exit(0);
}

