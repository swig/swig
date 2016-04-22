/*
 * NOTE: this won't run with -noexcept flag
 */

#include <stdio.h>
#include <assert.h>

#include "example_wrap.h"

static void show_exception(const char* prefix) {
  SWIG_CException* ex = SWIG_PendingException_get();
  assert(ex);
  printf("%s exception: %s (%d)\n", prefix, SWIG_CException_msg_get(ex), SWIG_CException_code_get(ex));
  SWIG_PendingException_reset();
}

int main() {
  Test *t = Test_new();

  Test_unknown(t);
  show_exception("Unknown");

  Test_simple(t);
  show_exception("Int");

  Test_message(t);
  show_exception("String");

  Test_hosed(t);
  show_exception("Custom");

  int i;
  for (i = 0; i < 4; ++i) {
    Test_multi(t, i);
    if (!SWIG_PendingException_get()) {
        printf("Success for i=%d\n", i);
    } else {
        printf("For i=%d", i);
        show_exception("");
    }
  }

  Test_delete(t);

  SWIG_exit(0);
}

