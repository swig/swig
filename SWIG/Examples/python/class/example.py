# file: example.py

# This file illustrates the low-level C++ interface
# created by SWIG.  In this case, all of our C++ classes
# get converted into function calls.

import example 

# ----- Object creation -----

print "Creating some objects:"
c = example.new_Circle(10)
print "    Created circle", c
s = example.new_Square(10)
print "    Created square", s

# ----- Access a static member -----

print "\nA total of", example.cvar.Shape_nshapes,"shapes were created"

# ----- Member data access -----

# Set the location of the object


example.Shape_x_set(c, 20)
example.Shape_y_set(c, 30)
example.Shape_x_set(s,-10)
example.Shape_y_set(s,5)

print "\nHere is their current position:"
print "    Circle = (%f, %f)" % (example.Shape_x_get(c), example.Shape_y_get(c))
print "    Square = (%f, %f)" % (example.Shape_x_get(s), example.Shape_y_get(s))

# ----- Call some methods -----

print "\nHere are some properties of the shapes:"
for o in [c,s]:
      print "   ", o
      print "        area      = ", example.Shape_area(o)
      print "        perimeter = ", example.Shape_perimeter(o)

# Notice how the Shape_area() and Shape_perimeter() functions really
# invoke the appropriate virtual method on each object.

# ----- Try to cause a type error -----

print "\nI'm going to try and break the type system"
try:
    # Bad script!
    Square_area(c)         # Try to invoke Square method on a Circle
    print "    Bad bad SWIG!"
except:
    print "    Well, it didn't work. Good SWIG."


# ----- Delete everything -----

print "\nGuess I'll clean up now"

# Note: this invokes the virtual destructor
example.delete_Shape(c)
example.delete_Shape(s)

print example.cvar.Shape_nshapes,"shapes remain"
print "Goodbye"

