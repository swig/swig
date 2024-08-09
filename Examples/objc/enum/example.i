/* File : example.i */
%module example

%{
#include "example.h"
%}

/* Force the generated Objective-C code to use the C enum values rather than making a method call */
//%objcconst(1);

/* Let's just grab the original header file here */

%include "example.h"

