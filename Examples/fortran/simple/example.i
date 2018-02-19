/* File : example.i */
%module simple

%inline %{
extern int    gcd(int x, int y);
extern double Foo;
%}
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
