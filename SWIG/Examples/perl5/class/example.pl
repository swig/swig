# file: example.pl

# This file illustrates the low-level C++ interface
# created by SWIG.  In this case, all of our C++ classes
# get converted into function calls.

use example;

# ----- Object creation -----

print "Creating some objects:\n";
$c = example::new_Circle(10);
print "    Created circle $c\n";
$s = example::new_Square(10);
print "    Created square $s\n";

# ----- Access a static member -----

print "\nA total of $example::Shape_nshapes shapes were created\n";

# ----- Member data access -----

# Set the location of the object.
# Note: methods in the base class Shape are used since
# x and y are defined there.

example::Shape_x_set($c, 20);
example::Shape_y_set($c, 30);
example::Shape_x_set($s,-10);
example::Shape_y_set($s,5);

print "\nHere is their current position:\n";
print "    Circle = (",example::Shape_x_get($c),",", example::Shape_y_get($c),")\n";
print "    Square = (",example::Shape_x_get($s),",", example::Shape_y_get($s),")\n";

# ----- Call some methods -----

print "\nHere are some properties of the shapes:\n";
foreach $o ($c,$s) {
      print "    $o\n";
      print "        area      = ", example::Shape_area($o), "\n";
      print "        perimeter = ", example::Shape_perimeter($o), "\n";
  }
# Notice how the Shape_area() and Shape_perimeter() functions really
# invoke the appropriate virtual method on each object.

# ----- Delete everything -----

print "\nGuess I'll clean up now\n";

# Note: this invokes the virtual destructor
example::delete_Shape($c);
example::delete_Shape($s);

print $example::Shape_nshapes," shapes remain\n";
print "Goodbye\n";

