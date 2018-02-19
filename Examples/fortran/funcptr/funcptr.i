/* File : funcptr.i */
%module funcptr
%{
#include "funcptr.h"
%}

/* Wrap a function taking a pointer to a function */
extern int  do_op(int a, int b, int (*op)(int, int));

/* Now install a bunch of "ops" as constants */
%constant int (*ADD)(int,int) = add;
%constant int (*SUB)(int,int) = sub;
%constant int (*MUL)(int,int) = mul;

extern int (*funcvar)(int,int);

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
