/* File : example.cxx */

#include "example.h"
#define M_PI 3.14159265358979323846

/* Move the shape to a new location */
void Shape::move(double dx, double dy) {
  x += dx;
  y += dy;
}

int Shape::nshapes = 0;

Circle::Circle(double r) : radius(r) {
  NumCircles++;
}

double Circle::area() {
  return M_PI*radius*radius;
}

double Circle::perimeter() {
  return 2*M_PI*radius;
}

Square::Square(double w) : width(w) {
  NumSquares++;
}

double Square::area() {
  return width*width;
}

double Square::perimeter() {
  return 4*width;
}

int NumSquares = 0;
int NumCircles = 0;

Square MakeSquare(double r) {
  return Square(r);
}

Circle MakeCircle(double w) {
  return Circle(w);
}

