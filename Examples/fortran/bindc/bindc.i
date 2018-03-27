/* File : bindc.i */
%module bindc

%fortran_bindc_struct(Point)

%{
#include "bindc.h"
%}

%newobject concat;

%include "bindc.h"


