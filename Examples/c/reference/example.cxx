#include <stdio.h>

#include "example.h"

void foo_by_val(Bar foo) {
  foo.set(123);
  printf("inside foo_by_val: %d\n", foo.get());
}

void foo_by_ref(Bar& foo) {
  foo.set(123);
  printf("inside foo_by_ref: %d\n", foo.get());
}

void foo_by_ptr(Bar* foo) {
  foo->set(123);
  printf("inside foo_by_ptr: %d\n", foo->get());
}

