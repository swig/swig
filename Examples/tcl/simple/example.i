/* File : example.i */
%module example
%{
/* Put headers and other declarations here */

char foo[] = "Help me!";
%}

typedef double *  DoublePtr;
typedef double Real;

typedef Vector *  Foo;

extern double My_variable;
extern int    fact(int);
extern int    mod(int n, int m);
extern char  *get_time();
char foo[];



