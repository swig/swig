#include "cpp11_rvalue_reference3/cpp11_rvalue_reference3_wrap.h"
#include <assert.h>

static int triple(int i) {
  return i * 3;
}

int main(int argc, const char *argv[]) {
  assert(cpp11_rvalue_reference3_funcref_takeit1(triple, 3) == 9);
  assert(cpp11_rvalue_reference3_funcref_takeit2(triple, 4) == 12);
  assert(cpp11_rvalue_reference3_funcref_takeit1(cpp11_rvalue_reference3_funcref_returnit1(), 5) == 10);
  assert(cpp11_rvalue_reference3_funcref_takeit2(cpp11_rvalue_reference3_funcref_returnit2(), 6) == 12);
  return 0;
}
