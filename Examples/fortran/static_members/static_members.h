/* File : static_members.h */
#include <iostream>

class BaseClass {
public:
  static int i;

  static double f(int x) { return 2.0 * x; }

private:
  static float j;
};
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
