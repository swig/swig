/* File : simple.cxx */

/** A global variable */
double Foo = 3.0;

/** Compute the greatest common divisor of positive integers */
int gcd(int x, int y) {
  int g;
  g = y;
  while (x > 0) {
    g = x;
    x = y % x;
    y = g;
  }
  return g;
}
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
