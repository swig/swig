/* File : bindc.i */
%module bindc

%fortranbindc_type(Point)

%{
#include "bindc.h"
%}

%newobject concat;

%include "bindc.h"


