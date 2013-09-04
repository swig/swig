/* File : example.i */
%module example

%{
#include "example.h"
#include "scilabconst_example.h"
%}

%include "example.h"

%scilabconst(1);

%include "scilabconst_example.h"
