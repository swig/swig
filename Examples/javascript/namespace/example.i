/* File : example.i */
%module example

%{
#include "example.h"
%}

%feature("nspace", 1);

%include "example.h"
