/* File : example.i */

/* This example has nothing to do with references but the name is used by all
 * the other languages so it's hard to rename to something more meaningful.
 *
 * Mostly it shows how to use %extend.
 */

%module example

%{
#include "example.h"
%}

class Vector {
public:
    Vector(double x, double y, double z);
   ~Vector();
    char *as_string();
};

/* This helper function calls an overloaded operator */
%inline %{
Vector addv(Vector &a, Vector &b) {
  return a+b;
}
%}

/* Wrapper around an array of vectors class */

class VectorArray {
public:
  VectorArray(int maxsize);
  ~VectorArray();
  int size();
  
 /*  This wrapper provides an alternative to the [] operator */
  %extend {
    Vector &get(int index) {
      printf("VectorArray extended get: %p %d\n",$self,index);
      return (*$self)[index];
    }
    void set(int index, Vector &a) {
      (*$self)[index] = a;
    }
  }
};
