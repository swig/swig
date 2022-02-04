/* File : example.i */
%module example

%{
#include "example.h"
%}

#ifdef SWIGFORTRAN
// Force constants to be a compile-time native fortran parameter
%fortranconst param_const;
%fortranconst MY_SPECIAL_NUMBERS;
%fortranconst approx_pi;
%fortranconst so_excited;
// Force constants to be defined in C++ but can be directly referenced in Fortran as link-time immutable variables
%fortranbindc octal_const;
%fortranbindc wrapped_const;
%fortranbindc weird_int;
#endif


// Compile-time/link-time constants
#define MY_SPECIAL_NUMBERS 5
%constant int param_const = 911;
%constant int octal_const = 0777;
%constant int wrapped_const = 0xdeadbeef;
%constant so_excited = "wheee";

// Ignore one of the functions that can't be overloaded correctly
%ignore cannot_overload(int);

%include "example.h"



