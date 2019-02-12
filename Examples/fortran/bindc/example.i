/* File : example.i */
%module example

%fortran_struct(Point)
%fortranbindc make_point;
%fortranbindc print_sphere;
%fortranbindc bound_negation;

%{
#include "example.h"
%}

%newobject concat;

%include "example.h"


