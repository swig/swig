/* File : example.i */
%module example
%{
#include "example.h"
%}

/* Wrap a function taking a pointer to a function */
extern int  do_op(int a, int b, int (*op)(int, int));

/* Now install a bunch of "ops" as constants */
%constant(int (*)(int,int)) ADD = add;
%constant(int (*)(int,int)) SUB = sub;
%constant(int (*)(int,int)) MUL = mul;


