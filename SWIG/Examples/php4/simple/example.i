/* File : example.i */
%module example

%{
   extern double Foo;
%}

extern double Foo;
void print_Foo();
int    gcd(int x, int y);
