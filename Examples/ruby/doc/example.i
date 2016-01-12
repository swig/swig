/* File : example.i */
%define DOCSTRING
"
This is an example
multi-line docstring.
"
%enddef

%module(docstring=DOCSTRING) example

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"
