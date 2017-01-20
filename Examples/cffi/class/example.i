/* File : example.i */
%module example

%feature("export");

%inline %{
#include "example.h"
%}
%include "example.h"


