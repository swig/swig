/** File example. This is the Simple Test File!
 */

%module example

%inline %{

/**   Function for Greater Common Divisor
 * Compute the greatest common divisor of positive integers 
 * @param x an integer argument.
 * @param y another integer argument.
 * @return the GCD
 */
extern int    gcd(int x, int y);

/** Global Variable Foo. Foo is the value of Foo. 
 */
extern double Foo;
%}
