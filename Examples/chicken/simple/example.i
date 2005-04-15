/* File : example.i */
%module example
%{
/* Put headers and other declarations here */
%}

%include typemaps.i

extern double My_variable;
extern int    fact(int);
%rename(mod) my_mod;
extern int    my_mod(int n, int m);
extern char   *get_time();
