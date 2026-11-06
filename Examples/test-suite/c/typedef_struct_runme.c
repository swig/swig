#include <stdio.h>
#include <stdlib.h>

#include "typedef_struct/typedef_struct_wrap.h"

static int callback_value = 0;

static void callback(int i) {
  callback_value = i;
}

int main() {
  int font = 3;
  FontSetObj font_set;
  Foo foo;
  BoolObj bool_obj = {true};
  A_t *a = typedef_struct_make_a();

  /* The members have the pointer types of the original struct */
  font_set.fonts = &font;
  foo.fptr = callback;
  foo.fptr(*font_set.fonts);
  if (callback_value != 3) {
    fprintf(stderr, "fptr failed\n");
    exit(1);
  }

  if (!bool_obj.visible) {
    fprintf(stderr, "visible failed\n");
    exit(1);
  }

  free(a);
  return 0;
}
