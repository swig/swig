#include <stdio.h>
#include <stdlib.h>

#include "arrays_null/arrays_null_wrap.h"

static void check_null_rejected(const char *test) {
  if (!arrays_null_SWIG_CException_get_pending()) {
    fprintf(stderr, "Test %s set to NULL failed\n", test);
    exit(1);
  }
  arrays_null_SWIG_CException_reset_pending();
}

static void check(int ok, const char *test) {
  if (!ok) {
    fprintf(stderr, "Test %s failed\n", test);
    exit(1);
  }
}

int main() {
  arrays_null_ArraysNull *s = arrays_null_ArraysNull_new();
  arrays_null_ArraysNull *other = arrays_null_ArraysNull_new();
  arrays_null_arrays_null_fill(other, 10);
  /* TODO: grid is not set from another array as its setter frees the array passed */
  arrays_null_ArraysNull_ints_set(s, arrays_null_ArraysNull_ints_get(other));
  check(arrays_null_ArraysNull_ints_get(s)[3] == 13, "member set");

  arrays_null_ArraysNull_ints_set(s, NULL);
  check_null_rejected("ints member");
  arrays_null_ArraysNull_grid_set(s, NULL);
  check_null_rejected("grid member");
  check(arrays_null_ArraysNull_ints_get(s)[3] == 13, "member set to NULL changed it");

  arrays_null_arrays_null_ints_set(arrays_null_ArraysNull_ints_get(s));
  check(arrays_null_arrays_null_ints_get()[3] == 13, "global set");

  arrays_null_arrays_null_ints_set(NULL);
  check_null_rejected("ints global");
  arrays_null_arrays_null_grid_set(NULL);
  check_null_rejected("grid global");
  arrays_null_arrays_null_bools_set(NULL);
  check_null_rejected("bools global");
  check(arrays_null_arrays_null_ints_get()[3] == 13, "global set to NULL changed it");

  check(arrays_null_arrays_null_ints_isnull(NULL), "NULL ints parameter");
  check(arrays_null_arrays_null_ints_unsized_isnull(NULL), "NULL ints unsized parameter");
  check(arrays_null_arrays_null_enums_isnull(NULL), "NULL enums parameter");
  check(arrays_null_arrays_null_enums_unsized_isnull(NULL), "NULL enums unsized parameter");
  check(arrays_null_arrays_null_items_isnull(NULL), "NULL items parameter");
  check(arrays_null_arrays_null_items_unsized_isnull(NULL), "NULL items unsized parameter");
  check(arrays_null_arrays_null_bools_isnull(NULL), "NULL bools parameter");
  check(arrays_null_arrays_null_bools_unsized_isnull(NULL), "NULL bools unsized parameter");
  check(arrays_null_arrays_null_chars_isnull(NULL), "NULL chars parameter");
  check(arrays_null_arrays_null_chars_unsized_isnull(NULL), "NULL chars unsized parameter");
  check(arrays_null_arrays_null_strings_isnull(NULL), "NULL strings parameter");
  check(arrays_null_arrays_null_strings_unsized_isnull(NULL), "NULL strings unsized parameter");

  arrays_null_ArraysNull_delete(other);
  arrays_null_ArraysNull_delete(s);
  exit(0);
}
