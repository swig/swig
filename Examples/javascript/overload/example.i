/* File : example.i */
%module example

%{
#include "example.h"
%}

/*
  Note: overloading is implemented in a sloppy way currently
        i.e., only the number of arguments is taken into conideration
        for dispatching.
        To solve the problem one has to rename such conflicting methods.
*/

%rename(f_string) f(const char* s);
%rename(f_bool) f(bool val);
%rename(f_long) f(long val);
%rename(f_double) f(double val);

%include "example.h"
