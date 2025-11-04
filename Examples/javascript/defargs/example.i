/* File : example.i */
%module example

%{
extern int  inci(int x, int step);
extern double incd(double d, double step, double mul);
%}

extern int  inci(int x, int step=1);
extern double incd(double d, double step=1.0, double mul=0.01);
