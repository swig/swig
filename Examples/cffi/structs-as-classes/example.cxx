/* File : example.cxx */

#include "example.h"
#include <stdio.h>

// all classes are declared in example.h

int Steve::the_struct_Steven_has_this_method(int a) {
  _a = a;
  printf("setting Steven._a to %d, and returning that value minus 1.\n",_a);
  return _a -1;
}

int Clarissa::the_class_Clarissa_has_this_method(int a) {
  _a = a;
  printf("setting Clarissa._a to %d, and returning that value minus 1.\n",_a);
  return _a -1;
}
