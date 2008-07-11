#include "example.h"

Bar foo_ret_val() {
  return Bar();
}

Bar *foo_ret_ptr(Bar *bar) {
  return bar;
}

Bar &foo_ret_ref(Bar &bar) {
  return bar;
}
