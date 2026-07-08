/* File : example.i */
%module example

%warnfilter(SWIGWARN_PARSE_KEYWORD) Shape::move;

%{
#include "example.h"
%}

%include "example.h"
