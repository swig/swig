/* File : example.i */

%module example

%{
#include "example.hxx"
%}

%include "std_vector.i"

%include "example.hxx";
