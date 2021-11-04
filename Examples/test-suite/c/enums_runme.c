#include <assert.h>
#include <stdlib.h>

#define SWIG_DEFINE_WRAPPER_ALIASES
#include "enums/enums_wrap.h"

int main() {
  assert(GlobalInstance == globalinstance1);
  assert(iFoo_Char == 'a');
  bar2(1);
  bar3(1);
  bar1(1);
  exit(0);
}

