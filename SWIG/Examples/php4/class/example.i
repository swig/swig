/* File : example.i */
%module example

%{
#include "example.h"
%}

%newobject *::Circle;
/* Let's just grab the original header file here */
%include "example.h"

