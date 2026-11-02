#include "cpp_new_expression/cpp_new_expression_wrap.h"
#include <assert.h>

using namespace cpp_new_expression;

int main(int argc, const char *argv[]) {
  // A member renamed to a C++ keyword is renamed again to its C++ name with a 'c_' prefix
  assert(NewNames::c_create() == 11);
  return 0;
}
