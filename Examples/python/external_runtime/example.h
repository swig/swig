/* File : example.h */

#include <iostream>
#include "Python.h"

class Mesh {
  int value_;
public:
  Mesh(const int value = 0) : value_(value) {}
  int value() { return value_; }
};

class MeshCaller {
  PyObject *pyObj_;
public:
  explicit MeshCaller(PyObject *pyCallable = 0);
};
