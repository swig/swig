module runme;

import std.stdio;
static import example;

void main() {
  /*
   * Call our gcd() function.
   */
  int x = 42;
  int y = 105;
  int g = example.gcd(x, y);
  writefln("The gcd of %s and %s is %s.", x, y, g);

  /*
   * Manipulate the Foo global variable.
   */

  // Output its current value
  writefln("Foo = %s", example.Foo);

  // Change its value
  example.Foo = 3.1415926;

  // See if the change took effect
  writefln("Foo = %s", example.Foo);
}
