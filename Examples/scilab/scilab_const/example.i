/* File : example.i */

%module example

%{
#include "example.h"
%}

/* Wraps enums and constants as Scilab variables (instead of functions) */
%scilabconst(1);

%include "example.h"

%constant int iconst = 37;
%constant double fconst = 42.2;
