#include <stdio.h>

#include "example_proxy.h"

int main(int argc, char** argv) {

  MyClass* mc = new_MyClass();
  A* a = new_A(123), *b = new_A(234), *as[5];
  int i, j = 321, *js[5];

  for (i = 0; i < 4; ++i) {
    as[i] = new_A(20 + i);
    js[i] = (int*) malloc(sizeof(int));
    *js[i] = 10 + i;
  }

  as[i] = 0;
  js[i] = 0;

  MyClass_bar(mc, j, &j, js);
  MyClass_foo(mc, *a, b, as);

  delete_A(a);
  delete_MyClass(mc);
}

