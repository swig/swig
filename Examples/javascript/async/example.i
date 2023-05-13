/* File : example.i */
%module example

%feature("async", "Async");
%feature("sync", "Sync");

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"
