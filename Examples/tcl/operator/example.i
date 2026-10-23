/* File : example.i */
%module example

%{
#include "example.h"
%}

// The overloaded operators and constructors are mostly handled automatically

// Ensure copy constructor is wrapped
%copyctor Complex;

%include "example.h"

/* An output method that turns a complex into a short string */
%extend Complex {
   char *str() {
       static char temp[512];
       sprintf(temp,"(%g,%g)", $self->re(), $self->im());
       return temp;
   }
};
