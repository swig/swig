#include <stdio.h>
#include <stdlib.h>

#include "c_structs/c_structs_wrap.h"

static void check(int ok, const char *test) {
  if (!ok) {
    fprintf(stderr, "Test %s failed\n", test);
    exit(1);
  }
}

int main() {
  struct Tagged tagged = {1};
  SameName same_name = {2};
  struct SameName *same_name_tag = &same_name;
  DiffName diff_name = {3};
  struct DiffTag *diff_tag = &diff_name;
  Anon anon = {4};
  Value value;
  union Value *value_tag = &value;
  AnonValue anon_value;

  check(ns_tagged_get(&tagged) == 1, "tagged_get");
  check(ns_same_name_get(&same_name) == 2, "same_name_get");
  check(ns_same_name_get(same_name_tag) == 2, "same_name_get with the tag");
  check(ns_diff_tag_get(diff_tag) == 3, "diff_tag_get");
  check(ns_diff_name_get(&diff_name) == 3, "diff_name_get");
  check(ns_anon_get(&anon) == 4, "anon_get");

  /* The union members share their storage, as in the wrapped code */
  value.d = 2.5;
  check(ns_value_get(&value) == 2.5, "value_get");
  check(ns_value_get(value_tag) == 2.5, "value_get with the tag");
  anon_value.d = 3.5;
  check(ns_anon_value_get(&anon_value) == 3.5, "anon_value_get");

  return 0;
}
