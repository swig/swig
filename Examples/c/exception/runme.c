/*
 * NOTE: this won't run with -noexcept flag
 */

#include <stdio.h>

#include "example_wrap.h"

int main() {
  Test *t = Test_new();

  SWIG_try {
    Test_unknown(t);
  }
  SWIG_catch(SWIG_AnyException) {
    printf("incomplete type: %s\n", SWIG_exc.msg);
  }
  SWIG_endtry;

  SWIG_try {
    Test_simple(t);
  }
  SWIG_catch(SWIG_AnyException) {
    printf("%s\n", SWIG_exc.msg);
  }
  SWIG_endtry;

  SWIG_try {
    Test_message(t);
  }
  SWIG_catch(SWIG_AnyException) {
    printf("%s\n", SWIG_exc.msg);
  }
  SWIG_endtry;

  SWIG_try {
    Test_hosed(t);
  }
  SWIG_catch(Exc) {
    printf("%d %s\n", Exc_code_get(SWIG_exc.klass), 
        Exc_msg_get(SWIG_exc.klass));
  }

  int i;
  for (i = 0; i < 4; ++i) {
    SWIG_try {
      Test_multi(t, i);
    }
    SWIG_catch(Exc) {
      printf("%d %s\n", Exc_code_get(SWIG_exc.klass), 
          Exc_msg_get(SWIG_exc.klass));
    }
    SWIG_catch(SWIG_AnyException) {
      printf("%s\n", SWIG_exc.msg);
    }
    SWIG_endtry;
  }

  SWIG_exit(0);
}

