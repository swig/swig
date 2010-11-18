// This example illustrates how C++ classes can be used from D using SWIG.
// The D class gets mapped onto the C++ class and behaves as if it is a D class.
module runme;

import std.stdio;
import example;

void main() {
  // ----- Object creation -----

  writeln( "Creating some objects:" );

  {
    scope Square s = new Square(10);
    scope Circle c = new Circle(10);

    // ----- Access a static member -----
    writefln( "%s shapes were created.", Shape.nshapes );

    // ----- Member data access -----

    // Notice how we can do this using functions specific to
    // the 'Circle' class.
    c.x = 20;
    c.y = 30;

    // Now use the same functions in the base class
    Shape shape = s;
    shape.x = -10;
    shape.y = 5;

    writeln( "\nHere is their current position:" );
    writefln( "    Circle = ( %s, %s )", c.x, c.y );
    writefln( "    Square = ( %s, %s )", s.x, s.y );

    // ----- Call some methods -----

    writeln( "\nHere are some properties of the shapes:" );
    Shape[] shapes = [ cast(Shape) c, cast(Shape) s ];
    foreach ( currentShape; shapes )
    {
      writefln( "    %s", currentShape.classinfo.name );
      writefln( "        area      = %s", currentShape.area() );
      writefln( "        perimeter = %s", currentShape.perimeter() );
    }

    // Notice how the area() and perimeter() functions really
    // invoke the appropriate virtual method on each object.

    // ----- Delete everything -----
    writeln( "\nGuess I'll clean up now:" );
    // Note: when this using scope is exited the D destructors are called which
    // in turn call the C++ destructors.
  }

  writefln( "%s shapes remain", Shape.nshapes );
  writeln( "\nGoodbye!" );
}
