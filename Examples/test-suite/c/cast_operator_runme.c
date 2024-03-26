#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cast_operator/cast_operator_wrap.h"

int main() {
  cast_operator_A *a = cast_operator_A_new();
  if (strcmp(cast_operator_A_tochar(a), "hi"))
    fprintf(stderr, "cast failed\n");
  cast_operator_A_delete(a);
  exit(0);
}

