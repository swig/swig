%module example
%{
#include "example.h"
%}

#define ENABLE_CHARPTR_ARRAY
#define ENABLE_STRING_VECTOR
%include stl.i

%include example.h
