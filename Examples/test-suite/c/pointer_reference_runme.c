#include <stdio.h>
#include <stdlib.h>

#include "pointer_reference/pointer_reference_wrap.h"

int main() {
  pointer_reference_Struct *s = pointer_reference_Struct_new(5);
  int i = 7;
  int *ip = &i;
  enum pointer_reference_Colour green = pointer_reference_GREEN;
  enum pointer_reference_Colour *colour = &green;

  /* A const reference to a pointer is just the pointer */
  if (pointer_reference_Struct_value_get(pointer_reference_get()) != 10) {
    fprintf(stderr, "get test failed\n");
    exit(1);
  }
  pointer_reference_set(s);
  if (pointer_reference_Struct_value_get(pointer_reference_Struct_instance_get()) != 5) {
    fprintf(stderr, "set test failed\n");
    exit(1);
  }
  if (pointer_reference_overloading_i(1) != 111) {
    fprintf(stderr, "overload test 1 failed\n");
    exit(1);
  }
  if (pointer_reference_overloading_rcpStruct(s) != 222) {
    fprintf(stderr, "overload test 2 failed\n");
    exit(1);
  }
  if (pointer_reference_pointer_reference_typedef_const(s) != 5) {
    fprintf(stderr, "pointer_reference_typedef_const failed\n");
    exit(1);
  }

  /* So is a const reference to a pointer to a class that is not wrapped */
  if (pointer_reference_opaque_value(pointer_reference_opaque_pointer()) != 30) {
    fprintf(stderr, "opaque_value failed\n");
    exit(1);
  }
  if (pointer_reference_opaque_pointer_reference() != pointer_reference_opaque_pointer()) {
    fprintf(stderr, "opaque_pointer_reference failed\n");
    exit(1);
  }

  /* So is a const reference to a pointer to a builtin type */
  if (pointer_reference_int_pointer_reference_value(ip) != 7) {
    fprintf(stderr, "int_pointer_reference_value failed\n");
    exit(1);
  }
  if (pointer_reference_int_pointer_pointer_reference_value(&ip) != 7) {
    fprintf(stderr, "int_pointer_pointer_reference_value failed\n");
    exit(1);
  }

  /* A reference to a pointer is a pointer to the pointer */
  if (pointer_reference_pointer_reference_value(&s) != 5) {
    fprintf(stderr, "pointer_reference_value failed\n");
    exit(1);
  }
  if (pointer_reference_pointer_reference_const_volatile(&s) != 5) {
    fprintf(stderr, "pointer_reference_const_volatile failed\n");
    exit(1);
  }
  if (pointer_reference_pointer_reference_typedef_volatile(&s) != 5) {
    fprintf(stderr, "pointer_reference_typedef_volatile failed\n");
    exit(1);
  }

  /* So is a reference to a pointer to an enum. A pointer to a pointer to an enum keeps both pointers */
  if (pointer_reference_colour_pointer_reference_value(&colour) != pointer_reference_GREEN) {
    fprintf(stderr, "colour_pointer_reference_value failed\n");
    exit(1);
  }
  if (pointer_reference_colour_pointer_pointer_value(&colour) != pointer_reference_GREEN) {
    fprintf(stderr, "colour_pointer_pointer_value failed\n");
    exit(1);
  }

  pointer_reference_Struct_delete(s);
  return 0;
}
