/* File : example.c */

#include "example.h"

#include <stdio.h>

#define M_PI 3.14159265358979323846

// Static member initializer
int Shape::nshapes = 0;

// Constructor
Shape::Shape() {
  nshapes++;
}

// Move the shape to a new location
void Shape::move(double dx, double dy) {
  x += dx;
  y += dy;
}

// Destructor
Shape::~Shape() {
  nshapes--;
}

// Circle area
double Circle::area() const {
  return M_PI*radius*radius;
}

// Circle perimeter
double Circle::perimeter() const {
  return 2*M_PI*radius;
}

// Square area
double Square::area() const {
  return width*width;
}

// Square perimeter
double Square::perimeter() const {
  return 4*width;
}
