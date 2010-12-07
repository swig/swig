/* File : example.i */
%module example
#pragma SWIG nowarn=SWIGWARN_IGNORE_OPERATOR_EQ
%{
#include "example.h"
%}

/* Now grab the original header file */
%include "example.h"

/* An output method that turns a complex into a short string */
%extend ComplexVal {
   char *__str() {
       static char temp[512];
       sprintf(temp,"(%g,%g)", $self->re(), $self->im());
       return temp;
   }

   ComplexVal __paren(int j) {
     return ComplexVal($self->re()*j,$self->im()*j);
   }
};


