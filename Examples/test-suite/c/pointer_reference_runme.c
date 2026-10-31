#include <stdio.h>
#include <stdlib.h>

#include "pointer_reference/pointer_reference_wrap.h"

int main() {
  pointer_reference_Struct *s = pointer_reference_Struct_new(5);

  /* A reference to a pointer is a pointer to the pointer */
  if (pointer_reference_pointer_reference_value(&s) != 5) {
    fprintf(stderr, "pointer_reference_value failed\n");
    exit(1);
  }
  if (pointer_reference_pointer_reference_const_volatile(&s) != 5) {
    fprintf(stderr, "pointer_reference_const_volatile failed\n");
    exit(1);
  }

  pointer_reference_Struct_delete(s);
  return 0;
}
