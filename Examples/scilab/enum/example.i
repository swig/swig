/* File : example.i */
%module example

%{
#include "example.h"
%}

/* Forces to wrap enums as Scilab variables (instead of functions) */
%scilabconst(1);

%include "example.h"


