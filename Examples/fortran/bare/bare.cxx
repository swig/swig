/* File : bare.cxx */

#include "bare.h"

#include <stdexcept>
#include <iostream>
using std::cout;
using std::endl;

namespace {
double data[10];
}

const int linked_const_int = -1234;

/* ------------------------------------------------------------------------- */
namespace foo {
int global_counter = 0;
}

/* ------------------------------------------------------------------------- */

void set_something(int x, double y) {
  if (!(x < 10))
    throw std::range_error("index out of range");
  data[x] = y;
}

double get_something(int x) {
  if (!(x < 10))
    throw std::range_error("index out of range");
  return data[x];
}

const double &get_something_rcref(int x) {
  return data[x];
}

double *get_something_rptr(int x) {
  return data + x;
}

const double *get_something_rcptr(int x) {
  return data + x;
}

double &get_something_rref(int x) {
  return data[x];
}

void get_something_ref(int x, double &y) {
  y = get_something(x);
}

void get_something_ptr(int x, double *y) {
  *y = get_something(x);
}

/* ------------------------------------------------------------------------- */

void print_rgb(RgbEnum c) {
  const char *str = "BAD RGB";

  switch (c) {
    case RED:
      str = "red";
      break;
    case GREEN:
      str = "green";
      break;
    case BLUE:
      str = "blue";
      break;
  }
  cout << str << endl;
}

/* ------------------------------------------------------------------------- */

void print_cmyk(CmykEnum c) {
  const char *str = "BAD CMYK";

  switch (c) {
    case CYAN:
      str = "CYAN";
      break;
    case MAGENTA:
      str = "MAGENTA";
      break;
    case YELLOW:
      str = "YELLOW";
      break;
    case BLACK:
      str = "BLACK";
      break;
  }
  cout << str << endl;
}

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
