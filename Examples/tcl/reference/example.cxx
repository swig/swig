/* File : example.cxx */

#include "example.h"
#include <stdio.h>
#include <stdlib.h>

Vector operator+(const Vector &a, const Vector &b) {
  Vector r;
  r.x = a.x + b.x;
  r.y = a.y + b.y;
  r.z = a.z + b.z;
  return r;
}

char *Vector::print() {
  static char temp[512];
  sprintf(temp,"Vector %p (%g,%g,%g)", this, x,y,z);
  return temp;
}

VectorArray::VectorArray(int size) {
  items = new Vector[size];
  maxsize = size;
}

VectorArray::~VectorArray() {
  delete [] items;
}

Vector &VectorArray::operator[](int index) {
  if ((index < 0) || (index >= maxsize)) {
    printf("Panic! Array index out of bounds.\n");
    exit(1);
  }
  return items[index];
}

int VectorArray::size() {
  return maxsize;
}

