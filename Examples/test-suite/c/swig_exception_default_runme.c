#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "swig_exception_default/swig_exception_default_wrap.h"

static void check_error(const char *test, int code, const char *msg) {
  if (error_code != code) {
    fprintf(stderr, "%s: error code should be %d, actually %d\n", test, code, error_code);
    exit(1);
  }
  if (code && strcmp(error_msg, msg) != 0) {
    fprintf(stderr, "%s: error message should be \"%s\", actually \"%s\"\n", test, msg, error_msg);
    exit(1);
  }
  error_code = 0;
  error_msg = NULL;
}

int main() {
  if (swig_exception_default_positive_only(5) != 5) {
    fprintf(stderr, "positive_only(5) failed\n");
    exit(1);
  }
  check_error("positive_only(5)", 0, NULL);

  /* The check typemap leaves the wrapper without calling positive_only, which would return -1 */
  if (swig_exception_default_positive_only(-1) != 0) {
    fprintf(stderr, "positive_only(-1) failed\n");
    exit(1);
  }
  check_error("positive_only(-1)", SWIG_ValueError, "Expected a positive value.");

  if (swig_exception_default_positive_result(5) != 5) {
    fprintf(stderr, "positive_result(5) failed\n");
    exit(1);
  }
  check_error("positive_result(5)", 0, NULL);

  /* The %exception code leaves the wrapper after positive_result returns -1 */
  if (swig_exception_default_positive_result(-1) != 0) {
    fprintf(stderr, "positive_result(-1) failed\n");
    exit(1);
  }
  check_error("positive_result(-1)", SWIG_ValueError, "Expected a positive result.");

  return 0;
}
