/* File : example.i */
%module(directors="1") example
%rename("FS%s", %$isclass) "";
%{
#include "example.h"
%}

%include "std_string.i"

/* turn on director wrapping Callback */
%feature("director") Callback;
%feature("director") CCallback;

%include "example.h"

