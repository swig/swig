/* File : example.i */
%module simple

%inline %{
extern int    gcd(int x, int y);
extern double Foo;
%}

