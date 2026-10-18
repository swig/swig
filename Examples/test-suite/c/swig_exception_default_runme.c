#include <stdio.h>
#include <stdlib.h>

#include "swig_exception_default/swig_exception_default_wrap.h"

int main() {
  if (swig_exception_default_positive_only(5) != 5) {
    fprintf(stderr, "positive_only(5) failed\n");
    exit(1);
  }

  /* The check typemap leaves the wrapper without calling positive_only, which would return -1 */
  if (swig_exception_default_positive_only(-1) != 0) {
    fprintf(stderr, "positive_only(-1) failed\n");
    exit(1);
  }

  if (swig_exception_default_positive_result(5) != 5) {
    fprintf(stderr, "positive_result(5) failed\n");
    exit(1);
  }

  /* The %exception code leaves the wrapper after positive_result returns -1 */
  if (swig_exception_default_positive_result(-1) != 0) {
    fprintf(stderr, "positive_result(-1) failed\n");
    exit(1);
  }

  return 0;
}
