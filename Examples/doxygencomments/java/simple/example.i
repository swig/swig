/* File : example.i */
%module example

%inline %{
/*! Function foo
 \param x int x
 \param y int y
 \return the gcd */
extern int    gcd(int x, int y);
extern double Foo; /*!< description of double foo */
%}
