/* File : example.i */
%module example

%fortranbindc my_global_var;

%fortran_struct(Point)
%fortranbindc make_point;
%fortranbindc print_sphere;
%fortranbindc bound_negation;

%{
#include "example.h"
%}

%newobject concat;

%include "example.h"


