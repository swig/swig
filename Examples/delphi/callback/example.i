/* File : example.i */
%module(directors="1") example
%{
#include "example.h"
%}

%include "std_string.i"

/* turn on director wrapping Callback */
%feature("director") Callback;

%include "example.h"
