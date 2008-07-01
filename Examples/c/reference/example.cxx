#include <stdio.h>

#include "example.h"

void foo_by_val(Bar bar) {
  bar.set(123);
  printf("inside foo_by_val: %d\n", bar.get());
}

void foo_by_ref(Bar& bar) {
  bar.set(123);
  printf("inside foo_by_ref: %d\n", bar.get());
}

void foo_by_ptr(Bar* bar) {
  bar->set(123);
  printf("inside foo_by_ptr: %d\n", bar->get());
}

