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
  assert(pointer_reference_typedef_const(&ss) == 20);

  int i = 7;
  int *ip = &i;
  assert(int_pointer_reference_value(ip) == 7);
  Colour green = GREEN;
  Colour *colour = &green;
  assert(colour_pointer_pointer_value(&colour) == GREEN);
  assert(colour_pointer_reference_value(colour) == GREEN);
  return 0;
}
