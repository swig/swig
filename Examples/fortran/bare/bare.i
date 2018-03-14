/* File : bare.i */
%module bare

%{
#include "bare.h"
%}

//! A const integer
// const int param_int = 4;
// const int wrapped_int = 0x1337;

#define MY_SPECIAL_NUMBERS 5
%constant int param_const = 911;
%constant int octal_const = 0777;
%constant int wrapped_const = 0xdeadbeef;

// Force a constant to be a compile-time native fortran parameter
%parameter approx_pi;

#ifdef SWIGFORTRAN
%include <typemaps.i>

// Instantiate array pointer conversion for doubles from pair<double*,size_t>
%fortran_view(double)

// Ignore one of the functions that can't be overloaded correctly
%ignore cannot_overload(int);

#endif

%include "bare.h"


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
