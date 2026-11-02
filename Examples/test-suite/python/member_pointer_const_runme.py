# Example using pointers to member functions

from member_pointer_const import *


def check(what, expected, actual):
    if expected != actual:
        raise RuntimeError(
            "Failed: ", what, " Expected: ", expected, " Actual: ", actual)

# Get the pointers

area_pt = areapt()
perim_pt = perimeterpt()

# Create some objects

s = Square(10)

# Do some calculations

check("Square area ", 100.0, do_op(s, area_pt))
check("Square perim", 40.0, do_op(s, perim_pt))

memberPtr = cvar.areavar
memberPtr = cvar.perimetervar

# Try the variables
check("Square area ", 100.0, do_op(s, cvar.areavar))
check("Square perim", 40.0, do_op(s, cvar.perimetervar))

# Modify one of the variables
cvar.areavar = perim_pt

check("Square perimeter", 40.0, do_op(s, cvar.areavar))

# Try the constants

memberPtr = AREAPT
memberPtr = PERIMPT
memberPtr = NULLPT

check("Square area ", 100.0, do_op(s, AREAPT))
check("Square perim", 40.0, do_op(s, PERIMPT))

# Typedefs
check("Square perim", 40.0, do_op_td(s, perim_pt));

# The declarators after the first in a list
check("Square perim", 40.0, do_op_list_td(s, perim_pt))
check("Square perim", 40.0, do_op(s, perimeterptlist()))
check("Square perim", 40.0, do_op(s, cvar.perimetervarlist))
check("Square perim", 40.0, do_op(s, MemberPointerGetter().getPerimeterPtList()))

# Member functions returning member pointers
getter = MemberPointerGetter()
check("Square area ", 100.0, do_op(s, getter.getAreaPt()))
check("Square area ", 100.0, do_op(s, getter.getConstAreaPt()))
check("Square area ", 100.0, do_op(s, MemberPointerGetter.getStaticAreaPt()))

# Member pointers to a namespaced class
adder = Adder()
check("Add by member pointer", 11, adder.callAddPt(adder.getAddPt(), 10))
if getAddPtDeclaration() != "int (MemberPointerSpace::Adder::*MemberPointerSpace::Adder::getAddPt())(int) const":
    raise RuntimeError("Incorrect declaration: " + getAddPtDeclaration())

check("Add by value", 3, call1(ADD_BY_VALUE, 1, 2))
#check("Add by pointer", 7, call2(ADD_BY_POINTER, 3, 4))
#check("Add by reference", 11, call3(ADD_BY_REFERENCE, 5, 6))
