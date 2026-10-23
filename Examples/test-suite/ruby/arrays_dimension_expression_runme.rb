#!/usr/bin/env ruby

require 'swig_assert'

require 'arrays_dimension_expression'

include Arrays_dimension_expression

# Setting an array with a dimension such as 'DIM_FLAGS | 4' copies all of its elements, and no more.
Arrays_dimension_expression.or_array = Arrays_dimension_expression.or_source
swig_assert_equal_simple(28, or_array_sum)
Arrays_dimension_expression.or_grid = Arrays_dimension_expression.or_grid_source
swig_assert_equal_simple(21, or_grid_sum)

Arrays_dimension_expression.or_text = "abcdef"
swig_assert_equal_simple("abcdef", Arrays_dimension_expression.or_text)
swig_assert_equal_simple(6, or_text_length("abcdef"))

Arrays_dimension_expression.and_array = Arrays_dimension_expression.and_source
swig_assert_equal_simple(3, and_array_sum)
Arrays_dimension_expression.and_grid = Arrays_dimension_expression.and_grid_source
swig_assert_equal_simple(10, and_grid_sum)

Arrays_dimension_expression.xor_array = Arrays_dimension_expression.xor_source
swig_assert_equal_simple(28, xor_array_sum)
Arrays_dimension_expression.xor_grid = Arrays_dimension_expression.xor_grid_source
swig_assert_equal_simple(105, xor_grid_sum)

Arrays_dimension_expression.eq_array = Arrays_dimension_expression.eq_source
swig_assert_equal_simple(5, eq_array_sum)
Arrays_dimension_expression.eq_grid = Arrays_dimension_expression.eq_grid_source
swig_assert_equal_simple(11, eq_grid_sum)

holder = DimensionHolder.new
holder.or_member = Arrays_dimension_expression.or_source
swig_assert_equal_simple(28, or_member_sum(holder))
holder.or_grid_member = Arrays_dimension_expression.or_grid_source
swig_assert_equal_simple(21, or_grid_member_sum(holder))
holder.or_text_member = "abcdef"
swig_assert_equal_simple("abcdef", holder.or_text_member)
