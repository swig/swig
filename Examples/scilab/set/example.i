/* File : example.i */

%module example

%{
#include "example.hxx"
%}

%include "std_set.i"

%include "matrix.i"
%apply (int size, int* matrixAsInput) { (const int size, const int* values) };

%include "example.hxx";
