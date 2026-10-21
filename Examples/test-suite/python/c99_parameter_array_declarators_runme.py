import c99_parameter_array_declarators
from c99_parameter_array_declarators import *
from swig_test_utils import swig_check, swig_assert, swig_assert_raises

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

# A %rename, %ignore or %exception given with an unnamed size parameter
swig_check(char_length_unnamed_renamed(5, "abc"), 3)
swig_assert(not hasattr(c99_parameter_array_declarators, "char_length_unnamed"), "char_length_unnamed not renamed")
swig_assert(not hasattr(c99_parameter_array_declarators, "char_length_ignored"), "char_length_ignored not ignored")
swig_check(char_length_excepted(5, "abc"), 3)

# Declared with an unspecified size and then with the size
swig_check(char_length_redeclared(5, "abc"), 3)
with swig_assert_raises(TypeError):
    char_length_redeclared(3, "abc")

# A method's size is the parameter n, not self
text = Text()
swig_check(text.char_length(5, "abc"), 3)
with swig_assert_raises(TypeError):
    text.char_length(3, "abc")

# A constructor and a function declared with its name in parentheses
swig_check(Name(5, "abc").length, 3)
with swig_assert_raises(TypeError):
    Name(3, "abc")
swig_check(char_length_parenthesized(5, "abc"), 3)
with swig_assert_raises(TypeError):
    char_length_parenthesized(3, "abc")
swig_check(char_length_parenthesized_unsized(5, "abc"), 3)

# A size that is a global variable is a fixed size
swig_check(sum_global_dimension(3, numbers), 6)

# A parameter's name used as a member name or in a literal does not refer to the parameter
sizes = Sizes()
sizes.n = 3
sizes.dims.n = 3
swig_check(char_length_member(sizes, 10, "ab"), 12)
with swig_assert_raises(TypeError):
    char_length_member(sizes, 10, "abcd")
swig_check(char_length_dot_member(sizes, 10, "ab"), 12)
with swig_assert_raises(TypeError):
    char_length_dot_member(sizes, 10, "abcd")
swig_check(char_length_literal(10, "a"), 11)
with swig_assert_raises(TypeError):
    char_length_literal(10, "ab")

# Variable length array type of unspecified size
swig_check(sum_n_unsized_renamed(3, numbers), 6)
swig_check(sum_n_unnamed(3, numbers), 6)

# Typedefs in a variable length array parameter
swig_check(sum_typedef_size(3, numbers), 6)
swig_check(sum_typedef_element(3, numbers), 6)
swig_check(char_length_typedef(5, "abc"), 3)
with swig_assert_raises(TypeError):
    char_length_typedef(3, "abc")
