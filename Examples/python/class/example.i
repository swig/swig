/* File : example.i */
%module example

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%typemap(memberin) char [ANY] {
    strncpy($target,$source,$dim0);
}

%include "example.h"

