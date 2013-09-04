/* File : example.c */

#include "example.h"
#include "scilabconst_example.h"
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

void scilabconst_enum_test(fruit f) {
  if (f == APPLE) {
    printf("fruit = APPLE\n");
  } else if (f == ORANGE) {
    printf("fruit = ORANGE\n");
  } else if (f == LEMON) {
    printf("fruit = LEMON\n");
  } else {
    printf("fruit = Unknown fruit!\n");
  }
}
