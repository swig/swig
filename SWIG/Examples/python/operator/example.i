/* File : example.i */
%module example

%{
#include "example.h"
%}

/* This header file is a little tough to handle because it has overloaded
   operators and constructors.  We're going to try and deal with that here */

/* This turns the copy constructor in a function ComplexCopy() that can
   be called */

%rename(ComplexCopy) Complex::Complex(Complex const &);

/* Convert some of the operators into Python special methods */
%rename(__add__) Complex::operator+(const Complex &c);
%rename(__sub__) Complex::operator-(const Complex &c);
%rename(__mul__) Complex::operator*(const Complex &c);
%rename(__neg__) Complex::operator-();
%rename(__str__) Complex::str;

/* Ignore assignment since Python doesn't really have an
   operator with equivalent semantics */

%ignore Complex::operator=;

/* Now grab the original header file */
%include "example.h"

/* An output method that turns a complex into a short string */
%addmethods Complex {
   char *str() {
       static char temp[512];
       sprintf(temp,"(%g,%g)", self->re(), self->im());
       return temp;
   }
};

