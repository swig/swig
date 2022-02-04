/* File : example.cxx */

#include "example.h"

#include <stdexcept>
#define M_PI 3.14159265358979323846

Shape::Shape() : x(0), y(0) {
  nshapes++;
}
Shape::~Shape() {
  nshapes--;
}

int Shape::nshapes = 0;

Circle::Circle(double r) : radius(r) {
  if (r <= 0)
    throw std::logic_error("Invalid radius");
}

double Circle::area() const {
  return M_PI * radius * radius;
}

double Circle::perimeter() const {
  return 2 * M_PI * radius;
}

double Square::area() const {
  return width * width;
}

double Square::perimeter() const {
  return 4 * width;
}

double surface_to_volume(const Shape &s) {
  return s.perimeter() / s.area();
}

Sphere::Sphere(double r) : radius(r) {
  if (r <= 0)
    throw std::logic_error("Invalid radius");
}

double Sphere::volume() const {
  return 4 * M_PI / 3 * radius * radius * radius;
}

