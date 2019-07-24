#include <assert.h>
#include <stdlib.h>

#include "enums/enums_wrap.h"

int main() {
  assert(GlobalInstance == globalinstance1);
  assert(Char == 'a');
  bar2(1);
  bar3(1);
  bar1(1);
  exit(0);
}

