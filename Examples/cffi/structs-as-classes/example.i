// Tests SWIG's newly added CFFI ability to treat structs as classes and
//  thereby to generate methods for structs just as if they were classes
//  with all public members (which they are, of course, but this feature
//  had been previously missing from the "swig -c++ -cffi" implementation).
%module example

%{
#include "example.h"
%}

%feature("export");

%include "example.h"
%include "example.cxx"
