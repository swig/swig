/* File : example.i */
%module example

#undef __cplusplus
#define __cplusplus 202211L
%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"
