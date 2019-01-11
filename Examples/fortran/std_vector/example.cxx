/* File : example.cxx */

#include "example.h"

#include <iostream>
using std::cout;
using std::endl;

/* -------------------------------------------------------------------------
 * FREE FUNCTIONS
 * ------------------------------------------------------------------------- */

template<class T>
void print_view(const T* data, std::size_t size) {
  cout << "{";
  const T *iter = data;
  const T *end = data + size;
  if (iter != end) {
    cout << *iter++;
  }
  while (iter != end) {
    cout << ", " << *iter++;
  }
  cout << "}" << endl;
}

/* -------------------------------------------------------------------------
 * EXPLICIT INSTANTIATION
 * ------------------------------------------------------------------------- */

template void print_view(const int* data, std::size_t size);



