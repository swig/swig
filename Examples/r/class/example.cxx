/* File : example.cxx */

#include "example.h"
#define M_PI 3.14159265358979323846

/* Move the shape to a new location */
void Shape::move(double dx, double dy) {
  x += dx;
  y += dy;
}

int Shape::nshapes = 0;

double Circle::area() {
  return M_PI*radius*radius;
}

double Circle::perimeter() {
  return 2*M_PI*radius;
}

Circle::Circle(double xx, double yy, double rr)
  : radius(rr)
{
  x = xx;
  y = yy;
}

bool Circle::operator==(const Circle & other)
{
  return x == other.x && y == other.y && radius == other.radius;
}

bool Circle::operator!=(const Circle & other)
{
  return !operator==(other);
}

double Square::area() {
  return width*width;
}

bool Square::operator==(const Square & other)
{
  return x == other.x && y == other.y && width == other.width;
}

bool Square::operator!=(const Square & other)
{
  return !operator==(other);
}

double Square::perimeter() {
  return 4*width;
}
