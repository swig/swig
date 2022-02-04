/* File : example.h */
#include <iostream>

class BaseClass {
public:
  static int i;

  static double f(int x) { return 2.0 * x; }

private:
  static float j;
};

