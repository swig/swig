from c99_parameter_array_declarators import *
from swig_test_utils import swig_check

numbers = three_numbers()

# Static and type qualifiers in parameter array declarators
swig_check(sum_static_renamed(numbers), 6)
swig_check(sum_const(numbers), 6)
swig_check(sum_qualified(numbers), 6)
swig_check(sum_const_static(numbers), 6)
swig_check(sum_qualifiers(numbers), 6)
swig_check(sum_qualifiers_only(numbers), 6)
swig_check(sum_unnamed(numbers), 6)

# Variable length array type of unspecified size
swig_check(sum_n_unsized_renamed(3, numbers), 6)
swig_check(sum_n_unnamed(3, numbers), 6)
