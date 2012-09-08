/* File : example.c */

#include <iostream>
#include "example.h"

#define M_PI 3.14159


/* A global variable */
namespace nspace
{
double Foo = 3.0;

/* Compute the greatest common divisor of positive integers */
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

Circle::Circle(): radius(1.0) {}

Circle::Circle(double r): radius(r) {
    std::cout << "created Circle with r=" << radius << std::endl;
}

double Circle::area() {
    std::cout << "Circle::area called, r=" << radius << std::endl;
    return M_PI*radius*radius;
}
}
