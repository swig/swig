#include "c_no_namespace_globals/c_no_namespace_globals_wrap.h"
#include <assert.h>

// The C names have no prefix, so the C type Counter would be ambiguous with 'using namespace'
namespace ns = c_no_namespace_globals;

static int thrice(int i) {
  return 3 * i;
}

int main(int argc, const char *argv[]) {
  ns::number(5);
  assert(ns::number() == 5);

  assert(ns::operation()(4) == 8);
  ns::operation(thrice);
  assert(ns::operation()(4) == 12);

  ns::Counter other;
  other.count(7);
  ns::counter(&other);
  ns::Counter *current = ns::counter();
  assert(current->count() == 7);
  delete current;
  return 0;
}
