/* File : example.i */
%module(directors="1") example
%{
#include "example.h"
%}

// %include "typemaps.i"
// %include "std_vector.i"
%include "std_string.i"

/* turn on director wrapping Callback */
%feature("director") Callback;

%include "example.h"

