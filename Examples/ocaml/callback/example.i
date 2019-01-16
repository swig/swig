/* File : example.i */
%module(directors="1") example
%{
#include "example.h"
%}

%feature("director") Callback;

%include "example.h"

