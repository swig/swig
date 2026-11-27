#include "cpp11_explicit_conversion_operators/cpp11_explicit_conversion_operators_wrap.h"
#include <assert.h>

using namespace cpp11_explicit_conversion_operators;

int main(int argc, const char *argv[]) {
  Testable t;
  assert(static_cast<int>(t) == 42);
  return 0;
}
