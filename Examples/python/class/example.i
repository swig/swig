/* File : example.i */
%module example

%{
#include "example.h"
%}

%typemap(in) double {
  /* hello */
}

/* Let's just grab the original header file here */
%include "example.h"
