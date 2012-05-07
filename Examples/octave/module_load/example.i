/* File : example.i */
%module example
%{
#include "example.h"
%}

extern "C" int ivar;

int ifunc();
