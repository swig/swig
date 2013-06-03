/* File : example.i */
%module example

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"

%template(ShapeDouble) Shape<double>;
%template(CircleDouble) Circle<double>;
%template(SquareDouble) Square<double>;

