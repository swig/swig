#include "import_callback_x.h"

extern "C" int go_for_it_y(int a, X x, int (X::*pf)(int a)) {
  return (x.*pf)(a) + 111;
}
