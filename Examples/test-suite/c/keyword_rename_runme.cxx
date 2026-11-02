#include "keyword_rename/keyword_rename_wrap.h"
#include <assert.h>

using namespace keyword_rename;

int main(int argc, const char *argv[]) {
  // A C++ keyword given by %rename is replaced by the C++ name with a 'c_' prefix
  assert(c_keyword_new(5) == 5);

  c_KeywordClass k;
  k.i(10);
  assert(k.i() == 10);

  assert(keyword_enum(c_KeywordEnumValue) == c_KeywordEnumValue);
  c_KeywordEnum e = c_KeywordEnumValue;
  assert(e == c_KeywordEnumValue);
  return 0;
}
