/* File : example.i */
%module Example
%{
/* Put headers and other declarations here */
%}

%inline %{
extern int    gcd(int x, int y);
extern double Foo;
%}

%include guile/guilemain.i
