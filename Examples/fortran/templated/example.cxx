/* File : example.cxx */
#include "example.h"

#include <iostream>
using std::cout;
using std::endl;

template<typename T>
Thing<T>::Thing(T val) : val_(val) {}

template<typename T>
T Thing<T>::get() const {
  return val_;
}

template<typename T>
void print_thing(const Thing<T> &t) {
  cout << "The thing is " << t.get() << endl;
}

template class Thing<int>;
template class Thing<double>;
template void print_thing<int>(const Thing<int> &);
template void print_thing<double>(const Thing<double> &);

