/* File : example.c */

#include "example.h"
#include <stdio.h>

void enum_test(color c) {
  if (c == RED) {
    printf("color = RED\n");
  } else if (c == BLUE) {
    printf("color = BLUE\n");
  } else if (c == GREEN) {
    printf("color = GREEN\n");
  } else {
    printf("color = Unknown color!\n");
  }
}
