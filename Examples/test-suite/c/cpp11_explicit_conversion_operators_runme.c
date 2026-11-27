#include "cpp11_explicit_conversion_operators/cpp11_explicit_conversion_operators_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
  cpp11_explicit_conversion_operators_Testable *t = cpp11_explicit_conversion_operators_Testable_new();
  assert(cpp11_explicit_conversion_operators_Testable_AsInteger(t) == 42);
  cpp11_explicit_conversion_operators_Testable_delete(t);
  return 0;
}
