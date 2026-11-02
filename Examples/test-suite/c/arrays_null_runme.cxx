#include "arrays_null/arrays_null_wrap.h"
#include <assert.h>

using namespace arrays_null;

int main(int argc, const char *argv[]) {
  // An array of a class is passed as a pointer to its first element
  ArraysNullItem item;
  assert(!arrays_null_items_isnull(&item));
  assert(!arrays_null_items_unsized_isnull(&item));
  assert(!arrays_null_const_items_isnull(&item));
  return 0;
}
