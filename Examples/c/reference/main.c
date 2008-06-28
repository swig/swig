#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char** argv) {
  Bar * bar = new_Bar();
  foo_by_ptr(bar);
  
  delete_Bar(bar);
  return 0;
}

