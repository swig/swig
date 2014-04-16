/* File : example.i */
%module swigexample

%inline %{
extern int    gcd(int x, int y);
extern double Foo;
%}
