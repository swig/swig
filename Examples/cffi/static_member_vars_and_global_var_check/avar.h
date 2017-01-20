#ifndef MICRO_H
#define  MICRO_H

#include <stdio.h>

class MicroTestCppClass {

public:
  MicroTestCppClass();
  int show();
  int take(int a);
  static int StaticPublicMemberInt;
};

extern int a_global_int;

#endif // MICRO_H
