/* File : bindc.i */
%module bindc

%fortran_bindc_struct(Point)

%{
#include "bindc.h"
%}

%include <cstring.i>
%apply const char* NATIVE { const char *, char * };

%newobject concat;

%include "bindc.h"

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
