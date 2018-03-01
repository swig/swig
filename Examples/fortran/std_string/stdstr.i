/* File : stdstr.i */
%module stdstr

%{
#include "stdstr.h"
%}

// Support native string conversions
%include <std_string.i>

%include "stdstr.h"


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
