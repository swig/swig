# Example using pointers to member functions

from member_pointer import *
from swig_test_utils import swig_assert_raises


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

# Const references to member pointers
check("Square area", 100.0, do_op_cref(s, area_pt))
check("Square perim", 40.0, do_op_cref(s, perimetervar_td_cref()))
check("Square perim", 40.0, do_op(s, perimetervar_td_cref()))
with swig_assert_raises(TypeError):
    do_op_cref(s, ADD_BY_VALUE)

check("Add by value", 3, call1(ADD_BY_VALUE, 1, 2))
check("Add by pointer", 7, call2(ADD_BY_POINTER, 3, 4))
check("Add by reference", 11, call3(ADD_BY_REFERENCE, 5, 6))

# Overloaded on the member pointer type
check("Overload by value", 3, call_overloaded(ADD_BY_VALUE, 1, 2))
check("Overload by pointer", -7, call_overloaded(ADD_BY_POINTER, 3, 4))
check("Overload by int", 110, call_overloaded(10, 5, 6))

# Overloaded on a member pointer and a pointer, only the pointer taking None
check("Overload by member pointer", 3, memberpt_or_pointer(ADD_BY_VALUE))
check("Overload by pointer", 10, memberpt_or_pointer(Funktions()))
check("Overload by None", 20, memberpt_or_pointer(None))
