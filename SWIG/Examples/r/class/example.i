/* File : example.i */
%module example

%inline %{
#include "example.h"
%}
%include "example.h"


