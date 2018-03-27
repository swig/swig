/* File : stdstr.i */
%module stdstr

%{
#include "stdstr.h"
%}

// Support native string conversions
%include <std_string.i>

%include "stdstr.h"



