import arrays_dimension_expression
from arrays_dimension_expression import cvar
from swig_test_utils import swig_check

# Setting an array with a dimension such as 'DIM_FLAGS | 4' copies all of its elements, and no more.
cvar.or_array = cvar.or_source
swig_check(arrays_dimension_expression.or_array_sum(), 28)

cvar.or_grid = cvar.or_grid_source
swig_check(arrays_dimension_expression.or_grid_sum(), 21)

cvar.or_text = "abcdef"
swig_check(cvar.or_text, "abcdef")
swig_check(arrays_dimension_expression.or_text_length("abcdef"), 6)

cvar.and_array = cvar.and_source
swig_check(arrays_dimension_expression.and_array_sum(), 3)
cvar.and_grid = cvar.and_grid_source
swig_check(arrays_dimension_expression.and_grid_sum(), 10)

cvar.xor_array = cvar.xor_source
swig_check(arrays_dimension_expression.xor_array_sum(), 28)
cvar.xor_grid = cvar.xor_grid_source
swig_check(arrays_dimension_expression.xor_grid_sum(), 105)

cvar.eq_array = cvar.eq_source
swig_check(arrays_dimension_expression.eq_array_sum(), 5)
cvar.eq_grid = cvar.eq_grid_source
swig_check(arrays_dimension_expression.eq_grid_sum(), 11)

holder = arrays_dimension_expression.DimensionHolder()
holder.or_member = cvar.or_source
swig_check(arrays_dimension_expression.or_member_sum(holder), 28)
holder.or_grid_member = cvar.or_grid_source
swig_check(arrays_dimension_expression.or_grid_member_sum(holder), 21)
holder.or_text_member = "abcdef"
swig_check(holder.or_text_member, "abcdef")
