/* File : example.i */
%module example

%{
#include "example.h"
%}

// The overloaded operators and constructors are mostly handled automatically

// Ensure copy constructor is wrapped
%copyctor Complex;

// Ignore the assignment operator to suppress a warning - the copy constructor can be used instead
%ignore Complex::operator=;

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


