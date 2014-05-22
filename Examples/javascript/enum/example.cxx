/* File : example.c */

#include "example.h"
#include <stdio.h>

void Foo::enum_test(speed s) {
  if (s == IMPULSE) {
    printf("IMPULSE speed\n");
  } else if (s == WARP) {
    printf("WARP speed\n");
  } else if (s == LUDICROUS) {
    printf("LUDICROUS speed\n");
  } else {
    printf("Unknown speed\n");
  }
}

void enum_test(color c, Foo::speed s) {
  if (c == RED) {
    printf("color = RED, ");
  } else if (c == BLUE) {
    printf("color = BLUE, ");
  } else if (c == GREEN) {
    printf("color = GREEN, ");
  } else {
    printf("color = Unknown color!, ");
  }
  if (s == Foo::IMPULSE) {
    printf("speed = IMPULSE speed\n");
  } else if (s == Foo::WARP) {
    printf("speed = WARP speed\n");
  } else if (s == Foo::LUDICROUS) {
    printf("speed = LUDICROUS speed\n");
  } else {
    printf("speed = Unknown speed!\n");
  }
}
