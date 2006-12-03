/* File : example.i */
%module example

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"

/* Some constants */

%constant double (Shape::*AREAPT)(void) = &Shape::area;
%constant double (Shape::*PERIMPT)(void) = &Shape::perimeter;
%constant double (Shape::*NULLPT)(void) = 0;
