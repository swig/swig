/* File : bindc.cxx */

#include "bindc.h"

#include <cstring>
#include <iostream>
using std::cout;
using std::endl;

/* -------------------------------------------------------------------------
 * \brief Print a point.
 */
void wrapped_print_point(const Point *p) {
  cout << "{" << p->x << ',' << p->y << ',' << p->z << "}" << endl;
}

const char* get_existing_string(int i) {
  if (i < 0)
    return "I can't deal with negatives";

  switch (i) {
    case 0:
      return "zero";
    case 1:
      return "one";
  }
  return "I can't count that high";
}

char* concat(const char* a, const char* b) {
  using std::strlen;
  using std::malloc;
  int len_a = strlen(a);
  int len_b = strlen(b);
  char* result = static_cast<char*>(malloc(len_a + len_b + 2));
  char* dst = result;
  memcpy(dst, a, len_a);
  dst += len_a;
  *dst++ = '+';
  memcpy(dst, b, len_b);
  dst += len_b;
  *dst++ = '\0';

  return result;
}

/* ------------------------------------------------------------------------- */

extern "C" {
void make_point(Point *pt, const double xyz[3]) {
  pt->x = xyz[0];
  pt->y = xyz[1];
  pt->z = xyz[2];
}

void print_sphere(const Point *origin, const double *radius) {
  cout << "Sphere: r=" << *radius
       << ", "
          "origin={"
       << origin->x << ',' << origin->y << ',' << origin->z << "}" << endl;
}
bool bound_negation(bool v) {
  return !v;
}
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
