#include <stdio.h>
#include <stdlib.h>

#include "enum_missing/enum_missing_wrap.h"

static int convert(int fmt) {
  return fmt + 1;
}

int main() {
  /* The enums are unknown, so int is used for them, also in the function pointer */
  global_fmt_converter = convert;
  if (global_fmt_converter(0) != 1 || enum_missing_use_pixel_format(1) != 1) {
    fprintf(stderr, "global_fmt_converter failed\n");
    exit(1);
  }
  return 0;
}
