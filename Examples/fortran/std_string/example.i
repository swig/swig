/* File : example.i */
%module example

%{
#include "example.h"
%}

// Support native string conversions
%include <std_string.i>

%include "example.h"



