// Tests SWIG's handling of pass-by-value for complex datatypes
%module example

%{
#include "example.h"
%}

%include "example.h"

/* Some helper functions for our interface */
%inline %{

void vector_print(Vector *v) {
  printf("Vector %x = (%g, %g, %g)\n", v, v->x, v->y, v->z);
}
%}

