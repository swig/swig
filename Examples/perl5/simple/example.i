/* File : example.i */
%module example
%{
/* Put headers and other declarations here */
%}


extern double My_variable;
extern int    fact(int);
%name(mod) extern int    my_mod(int n, int m);
extern char   *get_time();
