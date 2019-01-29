/* File : example.i */
%module example

%fortran_struct(Point)

%{
#include "example.h"
%}

%newobject concat;

%include "example.h"


