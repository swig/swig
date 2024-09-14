/*
 * NOTE: this won't run with -noexcept flag
 */

#include <stdio.h>
#include <assert.h>

#include "example_wrap.h"

using Exception = example::SWIG_CException;

static int exit_code = 0;

static void show_exception(const char* prefix, Exception const& ex) {
  printf("%s exception: %s (%d)\n", prefix, ex.msg(), ex.code());
}

static void missing_exception(const char* prefix) {
  printf("*** ERROR: %s: expected exception not thrown.\n", prefix);
  exit_code++;
}

int main() {
  example::Test t;

  try {
    t.unknown();
    missing_exception("Unknown");
  } catch (Exception const& e) {
    show_exception("Unknown", e);
  }

  try {
    t.simple();
    missing_exception("Int");
  } catch (Exception const& e) {
    show_exception("Int", e);
  }

  try {
    t.message();
    missing_exception("String");
  } catch (Exception const& e) {
    show_exception("String", e);
  }

  try {
    t.hosed();
    missing_exception("Custom");
  } catch (Exception const& e) {
    show_exception("Custom", e);
  }

  for (int i = 0; i < 4; ++i) {
    try {
      t.multi(i);
      if (i == 0) {
        printf("Success for i=%d\n", i);
      } else {
        missing_exception("Multi");
      }
    } catch (Exception const& e) {
      printf("For i=%d", i);
      show_exception("", e);
    }
  }

  return exit_code;
}
