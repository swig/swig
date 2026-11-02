#include "keyword_rename/keyword_rename_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
  keyword_rename_c_KeywordClass *k;

  // The C names of a C++ keyword given by %rename have the 'c_' prefix too
  assert(keyword_rename_c_keyword_new(5) == 5);

  k = keyword_rename_c_KeywordClass_new();
  keyword_rename_c_KeywordClass_i_set(k, 10);
  assert(keyword_rename_c_KeywordClass_i_get(k) == 10);
  keyword_rename_c_KeywordClass_delete(k);

  assert(keyword_rename_keyword_enum(keyword_rename_c_KeywordEnumValue) == keyword_rename_c_KeywordEnumValue);
  return 0;
}
