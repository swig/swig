/* File : example.c */

#include "example.h"
#include <stdio.h>

void enum_test(color c) {
  if (c == RED) {
    sciprint("color = RED, ");
  } else if (c == BLUE) {
    sciprint("color = BLUE, ");
  } else if (c == GREEN) {
    sciprint("color = GREEN, ");
  } else {
    sciprint("color = Unknown color!, ");
  }
}
