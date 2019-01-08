/* File : example.i */
%module example

%fortranbindc_type(Point)

%{
#include "example.h"
%}

%newobject concat;

%include "example.h"


