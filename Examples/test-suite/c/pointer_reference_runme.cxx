#include "pointer_reference/pointer_reference_wrap.h"
#include <assert.h>

using namespace pointer_reference;

int main() {
  Struct *s = get();
  assert(s->value() == 10);
  delete s;

  Struct ss(20);
  set(&ss);
  Struct *instance = Struct::instance();
  assert(instance->value() == 20);
  delete instance;

  assert(overloading(1) == 111);
  assert(overloading(&ss) == 222);
  return 0;
}
