/* File : example.i */
/** Let's document module Example! */
%module(directors="1") example
%{
#include "example.h"
%}

%include "std_string.i"

/* turn on director wrapping Callback */
%feature("director") Callback;

%include "example.h"

