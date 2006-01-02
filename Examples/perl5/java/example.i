%module example

%{
#undef STATIC
%}
%include <gcj/cni.i>
%include <jstring.i>
%{
#undef TRUE
#define TRUE 1
%}

%{
#include "Example.h"
%}


%include Example.h
