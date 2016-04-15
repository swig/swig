#include <assert.h>

#include "enums/enums_wrap.h"

int main() {
  assert(GlobalInstance == globalinstance1);
  assert(Char == 'a');
  bar2(1);
  bar3(1);
  bar1(1);
  SWIG_exit(0);
}

