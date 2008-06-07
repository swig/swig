/* File : example.i */
%module example

%inline %{
extern double Foo;
extern int gcd(int x, int y);
%}

