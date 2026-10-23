import cpp11_rvalue_reference_array as rra
from swig_test_utils import swig_check, swig_assert_raises

# An rvalue reference to an array is passed as a reference to an array, which cannot be None.
swig_check(rra.sum_of(rra.others_address()), 100)
swig_check(rra.first_of(rra.others_unsized_address()), 10)
swig_check(rra.items_sum(rra.items_address()), 3)
with swig_assert_raises(TypeError):
    rra.sum_of(None)
with swig_assert_raises(TypeError):
    rra.first_of(None)

# An rvalue reference to an array of char is a string.
swig_check(rra.length_of("abc"), 3)
swig_check(rra.length_of_writable("xy"), 2)
with swig_assert_raises(TypeError):
    rra.length_of(None)

# Setting a variable that is an rvalue reference to an array copies into the array it refers to.
swig_check(rra.numbers_sum(), 10)
rra.cvar.numbers_rref = rra.cvar.others
swig_check(rra.numbers_sum(), 100)
swig_check(rra.cvar.letters_rref, "abc")
rra.cvar.letters_rref = "xy"
swig_check(rra.letters_are(), "xy")

member = rra.RvalueRefArrayMember()
swig_check(member.sum(), 10)
member.member_rref = rra.others_address()
swig_check(member.sum(), 100)
swig_check(member.text_rref, "hi")
member.text_rref = "bye"
swig_check(member.text_is(), "bye")
