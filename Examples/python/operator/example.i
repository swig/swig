/* File : example.i */
%module example
#pragma SWIG nowarn=SWIGWARN_IGNORE_OPERATOR_EQ
%{
#include "example.h"
%}

/* This header file is a little tough to handle because it has overloaded
   operators and constructors.  We're going to try and deal with that here */

/* This turns the copy constructor in a function ComplexCopy() that can
   be called */

%rename(ComplexCopy) Complex::Complex(Complex const &);

/* Now grab the original header file */
%include "example.h"

/* An output method that turns a complex into a short string */
%feature("python:slot", "tp_str", functype="reprfunc") Complex::__str__; // For -builtin option to use __str__ in the tp_str slot
%extend Complex {
   char *__str__() {
       static char temp[512];
       sprintf(temp,"(%g,%g)", $self->re(), $self->im());
       return temp;
   }
};


