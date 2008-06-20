#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char **argv) {
  struct CircleObj* pc = new_Circle(10.0);

  // ...
  
  delete_Circle(pc);
}

