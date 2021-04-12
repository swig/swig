# file: runme.py

# This file illustrates the proxy class C++ interface generated
# by SWIG.

import example

# ----- Object creation -----

print("Creating some objects:")
cc = example.Circle(10)
c = example.ShapePtr(cc)
print("    Created circle %s" % c)
ss = example.Square(10)
s = example.ShapePtr(ss)
print("    Created square %s" % s)

# ----- Access a static member -----

print("\nA total of %s shapes were created" % example.cvar.Shape_nshapes)

# ----- Member data access -----

# Set the location of the object

c.x = 20
c.y = 30

s.x = -10
s.y = 5

print("\nHere is their current position:")
print("    Circle = (%f, %f)" % (c.x, c.y))
print("    Square = (%f, %f)" % (s.x, s.y))

# ----- Call some methods -----

print("\nHere are some properties of the shapes:")
for o in [c, s]:
    print("    %s" % o)
    print("        area      = %s" % o.area())
    print("        perimeter = %s" % o.perimeter())

print("\nGuess I'll clean up now")

# Note: this invokes the virtual destructor
del c
del s
del cc
del ss

s = 3
print("%d shapes remain" % example.cvar.Shape_nshapes)
print("Goodbye")
