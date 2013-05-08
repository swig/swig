/* File : example.i */
%module swigexample

%{
#include "example.h"
%}

/* Let's just grab the original header file here */

%include "example.h"
