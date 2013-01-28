// This example illustrates how C++ classes can be used from D using SWIG.
// The D class gets mapped onto the C++ class and behaves as if it is a D class.
module runme;

import tango.io.Stdout;
import example;

void main() {
  // ----- Object creation -----

  Stdout( "Creating some objects:" ).newline;

  {
    scope Square s = new Square(10);
    scope Circle c = new Circle(10);

    // ----- Access a static member -----
    Stdout.format( "{} shapes were created.", Shape.nshapes ).newline;

    // ----- Member data access -----

    // Notice how we can do this using functions specific to
    // the 'Circle' class.
    c.x = 20;
    c.y = 30;

    // Now use the same functions in the base class
    Shape shape = s;
    shape.x = -10;
    shape.y = 5;

    Stdout( "\nHere is their current position:" ).newline;
    Stdout.format( "    Circle = ( {}, {} )", c.x, c.y ).newline;
    Stdout.format( "    Square = ( {}, {} )", s.x, s.y ).newline;

    // ----- Call some methods -----

    Stdout( "\nHere are some properties of the shapes:" ).newline;
    Shape[] shapes = [ cast(Shape) c, cast(Shape) s ];
    foreach ( currentShape; shapes )
    {
      Stdout.format( "    {}", currentShape.classinfo.name ).newline;
      Stdout.format( "        area      = {}", currentShape.area() ).newline;
      Stdout.format( "        perimeter = {}", currentShape.perimeter() ).newline;
    }

    // Notice how the area() and perimeter() functions really
    // invoke the appropriate virtual method on each object.

    // ----- Delete everything -----
    Stdout( "\nGuess I'll clean up now:" ).newline;
    // Note: when this using scope is exited the D destructors are called which
    // in turn call the C++ destructors.
  }

  Stdout.format( "{} shapes remain", Shape.nshapes ).newline;
  Stdout( "\nGoodbye!" ).newline;
}
