import arrayref
from swig_test_utils import swig_check

# A global variable that is a reference to an array reads as the array it refers to.
swig_check(arrayref.cvar.numbers_ref, arrayref.cvar.numbers)

# Setting one copies the elements into the array it refers to.
swig_check(arrayref.numbers_sum(), 10)
arrayref.cvar.numbers_ref = arrayref.cvar.others
swig_check(arrayref.numbers_sum(), 100)

# A reference to an array of char is a string, as the array it refers to is.
swig_check(arrayref.cvar.letters, "abc")
swig_check(arrayref.cvar.letters_ref, "abc")
arrayref.cvar.letters_ref = "xy"
swig_check(arrayref.letters_are(), "xy")

# So is an argument that is a reference to an array of char.
swig_check(arrayref.length_of("abc"), 3)
swig_check(arrayref.length_of_writable("xy"), 2)

# A reference to an array of const is read only.
swig_check(arrayref.cvar.frozen_ref, "xyz")

member = arrayref.ArrayRefMember()
swig_check(member.sum(), 10)
member.member_ref = arrayref.others_address()
swig_check(member.sum(), 100)

# The same for a member that is a reference to an array of char.
swig_check(member.text_ref, "hi")
member.text_ref = "bye"
swig_check(member.text_is(), "bye")

# Setting a reference to an array of arrays copies every element.
arrayref.cvar.grid_ref = arrayref.cvar.other_grid
swig_check(arrayref.grid_element(0, 1), 20)
swig_check(arrayref.grid_element(1, 2), 60)

grid_member = arrayref.GridRefMember()
grid_member.rows_ref = arrayref.other_grid_address()
swig_check(grid_member.element(0, 1), 20)
swig_check(grid_member.element(1, 2), 60)

# Setting a reference to an array of pointers copies the pointers.
pointer_holder = arrayref.PointerRefArrayHolder()
pointer_holder.elements_ref = arrayref.pointers_address()
swig_check(arrayref.holds_pointers(pointer_holder), True)
