/* File : example.i */
%module example

%{
#include "example.h"
%}

%pragma make_default

/* Let's just grab the original header file here */

%include "example.h"

