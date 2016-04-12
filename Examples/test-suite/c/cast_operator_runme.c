#include <stdio.h>

#include "cast_operator/cast_operator_wrap.h"

int main() {
  A *a = new_A();
  if (strcmp(A_tochar(a), "hi"))
    fprintf(stderr, "cast failed\n");
  delete_A(a);
  SWIG_exit(0);
}

