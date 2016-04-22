#include <stdio.h>

#include "cast_operator/cast_operator_wrap.h"

int main() {
  A *a = A_new();
  if (strcmp(A_tochar(a), "hi"))
    fprintf(stderr, "cast failed\n");
  A_delete(a);
  SWIG_exit(0);
}

