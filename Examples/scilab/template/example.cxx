/* File : example.c */

#include "example.h"
#define M_PI 3.14159265358979323846

template<typename T>
void Shape<T>::move(T dx, T dy) {
  x += dx;
  y += dy;
}

template<typename T>
int Shape<T>::nbshapes = 0;

template<typename T>
int Shape<T>::getNbShapes() {
  return Shape<T>::nbshapes;
}

template<typename T>
T Circle<T>::area() {
  return M_PI*radius*radius;
}

template<typename T>
T Circle<T>::perimeter() {
  return 2*M_PI*radius;
}

template<typename T>
T Square<T>::area() {
  return width*width;
}

template<typename T>
T Square<T>::perimeter() {
  return 4*width;
}

template class Shape<double>;
template class Square<double>;
template class Circle<double>;

