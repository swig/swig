#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "swig_exception/swig_exception_wrap.h"

static void check_exception(const char *test, int code, const char *msg) {
  swig_exception_SWIG_CException *ex = swig_exception_SWIG_CException_get_pending();
  if (!ex) {
    fprintf(stderr, "%s: exception wasn't thrown\n", test);
    exit(1);
  }
  if (swig_exception_SWIG_CException_code_get(ex) != code) {
    fprintf(stderr, "%s: exception code should be %d, actually %d\n", test, code, swig_exception_SWIG_CException_code_get(ex));
    exit(1);
  }
  if (strcmp(swig_exception_SWIG_CException_msg_get(ex), msg) != 0) {
    fprintf(stderr, "%s: exception message should be \"%s\", actually \"%s\"\n", test, msg, swig_exception_SWIG_CException_msg_get(ex));
    exit(1);
  }
  swig_exception_SWIG_CException_reset_pending();
}

int main() {
  swig_exception_Circle *c = swig_exception_Circle_new(10);
  swig_exception_Square *s = swig_exception_Square_new(10);

  if (swig_exception_Shape_nshapes_get() != 2) {
    fprintf(stderr, "Shape.nshapes should be 2, actually %d\n", swig_exception_Shape_nshapes_get());
    exit(1);
  }

  /* ----- Throw exception ----- */
  if (swig_exception_Circle_throwException(c)) {
    fprintf(stderr, "throwException should return NULL\n");
    exit(1);
  }
  check_exception("throwException", SWIG_SystemError, "OK");

  if (swig_exception_throwIndexError() != 0) {
    fprintf(stderr, "throwIndexError should return 0\n");
    exit(1);
  }
  check_exception("throwIndexError", SWIG_IndexError, "index out of range");

  if (swig_exception_throwInt() != 0) {
    fprintf(stderr, "throwInt should return 0\n");
    exit(1);
  }
  check_exception("throwInt", SWIG_RuntimeError, "int 1 thrown");

  /* ----- Delete everything ----- */
  swig_exception_Circle_delete(c);
  swig_exception_Square_delete(s);

  if (swig_exception_Shape_nshapes_get() != 0) {
    fprintf(stderr, "Shape.nshapes should be 0, actually %d\n", swig_exception_Shape_nshapes_get());
    exit(1);
  }

  return 0;
}
