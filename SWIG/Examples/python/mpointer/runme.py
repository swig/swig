# Example using pointers to member functions

import example

# Get the pointers

area_pt = example.areapt()
perim_pt = example.perimeterpt()

print "area_pt  =", area_pt
print "perim_pt = ", perim_pt

# Create some objects

c = example.Circle(4)
s = example.Square(10)

# Do some calculations

print "Circle area  = ", example.do_op(c,area_pt)
print "Circle perim = ", example.do_op(c,perim_pt)
print "Square area  = ", example.do_op(s,area_pt)
print "Square perim = ", example.do_op(s,perim_pt)

print "cvar.areavar      =", example.cvar.areavar
print "cvar.perimetervar =", example.cvar.perimetervar

# Try the variables
print "Circle area  = ", example.do_op(c,example.cvar.areavar)
print "Circle perim = ", example.do_op(c,example.cvar.perimetervar)
print "Square area  = ", example.do_op(s,example.cvar.areavar)
print "Square perim = ", example.do_op(s,example.cvar.perimetervar)

# Modify one of the variables
example.cvar.areavar = perim_pt

print "Circle perimeter = ", example.do_op(c,example.cvar.areavar)

# Try the constants

print "example.AREAPT =", example.AREAPT
print "example.PERIMPT=", example.PERIMPT
print "example.NULLPT =", example.NULLPT

print "Circle area  = ", example.do_op(c,example.AREAPT)
print "Circle perim = ", example.do_op(c,example.PERIMPT)
print "Square area  = ", example.do_op(s,example.AREAPT)
print "Square perim = ", example.do_op(s,example.PERIMPT)



