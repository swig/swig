import arrays_dimension_expression
from arrays_dimension_expression import cvar
from swig_test_utils import swig_check

# Setting an array sized 'DIM_FLAGS | 4' copies its 7 elements, and no more.
cvar.or_array = cvar.or_source
swig_check(arrays_dimension_expression.or_array_sum(), 28)

cvar.or_grid = cvar.or_grid_source
swig_check(arrays_dimension_expression.or_grid_sum(), 21)

cvar.or_text = "abcdef"
swig_check(cvar.or_text, "abcdef")
swig_check(arrays_dimension_expression.or_text_length("abcdef"), 6)

holder = arrays_dimension_expression.DimensionHolder()
holder.or_member = cvar.or_source
swig_check(arrays_dimension_expression.or_member_sum(holder), 28)
holder.or_grid_member = cvar.or_grid_source
swig_check(arrays_dimension_expression.or_grid_member_sum(holder), 21)
holder.or_text_member = "abcdef"
swig_check(holder.or_text_member, "abcdef")
