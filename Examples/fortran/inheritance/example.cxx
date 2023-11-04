/* File : example.cxx */
#include "example.h"

#include <iostream>

BaseClass::BaseClass() : _i(-1) {
  std::cout << "BaseClass::BaseClass()\n";
  return;
}
BaseClass::BaseClass(int i_in) : _i(i_in) {
  std::cout << "BaseClass::BaseClass(int)\n";
  return;
}
BaseClass::~BaseClass() {
  std::cout << "BaseClass::~BaseClass()\n";
  return;
}

DerivedA::DerivedA() : _f(-1.0), _data() {
  std::cout << "DerivedA::DerivedA()\n";
  return;
}

DerivedA::DerivedA(int i, float f) : BaseClass(i), _f(f), _data(i, 0) {
  std::cout << "DerivedA::DerivedA(int, float)\n";
  for (int ii = 0; ii < i; ii++) {
    _data[ii] = ii;
  }
  return;
}

DerivedA::~DerivedA() {
  std::cout << "DerivedA::~DerivedA()\n";
  return;
}

float DerivedA::foo() const {
  return BaseClass::get_i() * _f;
}

void DerivedA::print() const {
  for (std::vector<int>::const_iterator it = _data.begin(); it != _data.end(); ++it) {
    std::cout << *it << " ";
  }
  std::cout << "\n";
  return;
}

DerivedB::DerivedB() : _i2(-1) {
  std::cout << "DerivedB::DerivedB()\n";
  return;
}
DerivedB::DerivedB(int i, int i2) : BaseClass(i), _i2(i2) {
  std::cout << "DerivedB::DerivedB(int, int)\n";
  return;
}
DerivedB::~DerivedB() {
  std::cout << "DerivedB::~DerivedB()\n";
  return;
}
float DerivedB::foo() const {
  return BaseClass::get_i() * _i2 * 2;
}

