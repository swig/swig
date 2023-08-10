/* File : example.i */
%module example

%{
#include "example.h"
%}

%include "std_string.i"

%catches(int) Test::simple();
%catches(const char *) Test::message();
%catches(Exc) Test::hosed();
%catches(A*) Test::unknown();
%catches(int, const char *, Exc) Test::multi(int x);

/* Let's just grab the original header file here */
%include "example.h"

