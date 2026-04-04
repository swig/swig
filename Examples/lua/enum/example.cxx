#include "example.h"
#include <stdio.h>

void Foo::enum_test(speed s) {
  switch(s) {
    case IMPULSE:   printf("IMPULSE speed\n"); break;
    case WARP:      printf("WARP speed\n"); break;
    case LUDICROUS: printf("LUDICROUS speed\n"); break;
    default:        printf("Unknown speed\n"); break;
  }
}

void enum_test(color c, Foo::speed s) {
  switch(c) {
    case RED:   printf("color = RED, "); break;
    case BLUE:  printf("color = BLUE, "); break;
    case GREEN: printf("color = GREEN, "); break;
    default:    printf("color = Unknown color!, "); break;
  }
  switch(s) {
    case Foo::IMPULSE:   printf("speed = IMPULSE speed\n"); break;
    case Foo::WARP:      printf("speed = WARP speed\n"); break;
    case Foo::LUDICROUS: printf("speed = LUDICROUS speed\n"); break;
    default:             printf("speed = Unknown speed!\n"); break;
  }
}
