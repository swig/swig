from c99_parameter_array_declarators import *
from swig_test_utils import swig_check, swig_assert_raises

numbers = three_numbers()

# Static and type qualifiers in parameter array declarators
swig_check(sum_static_renamed(numbers), 6)
swig_check(sum_const(numbers), 6)
swig_check(sum_qualified(numbers), 6)
swig_check(sum_const_static(numbers), 6)
swig_check(sum_qualifiers(numbers), 6)
swig_check(sum_qualifiers_only(numbers), 6)
swig_check(sum_unnamed(numbers), 6)

# Variable length array type, the size being an earlier parameter in the parameter list
swig_check(sum_n_renamed(3, numbers), 6)
swig_check(sum_n_static_renamed(3, numbers), 6)
swig_check(char_length(5, "abc"), 3)
swig_check(char_length(4, "abc"), 3)
with swig_assert_raises(TypeError):
    char_length(3, "abc")
with swig_assert_raises(ValueError):
    char_length(0, "")
swig_check(char_length(0, None), 0)
swig_check(char_length(-1, None), 0)
swig_check(char_length_offset(1, 5, "abc"), 3)
with swig_assert_raises(TypeError):
    char_length_offset(2, 5, "abc")

# A method's size is the parameter n, not self
text = Text()
swig_check(text.char_length(5, "abc"), 3)
with swig_assert_raises(TypeError):
    text.char_length(3, "abc")

# A size that is a global variable is a fixed size
swig_check(sum_global_dimension(3, numbers), 6)

# Variable length array type of unspecified size
swig_check(sum_n_unsized_renamed(3, numbers), 6)
swig_check(sum_n_unnamed(3, numbers), 6)
