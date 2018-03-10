/* File : example.i */
%module example

%{
// We must declare a function pointer typedef in order to generate its declaration
typedef int (*funptr)(int,int);
%}
typedef int (*funptr)(int,int);
%{
#include "example.h"
%}



/* Wrap a function taking a pointer to a function */
//extern int  do_op(int a, int b, int (*op)(int, int));
//extern int  do_op(int a, int b, funptr);
/* Now install a bunch of "ops" as constants */
extern int add(int,int);
extern int sub(int,int);
extern int mul(int,int);

extern funptr funcvar;