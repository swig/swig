using System;
using arrays_dimension_expressionNamespace;

public class runme {
  static void Main() {
    // Setting an array with a dimension such as 'DIM_FLAGS | 4' copies all of its elements, and no more.
    arrays_dimension_expression.or_array = arrays_dimension_expression.or_source;
    check(28, arrays_dimension_expression.or_array_sum());
    arrays_dimension_expression.or_grid = arrays_dimension_expression.or_grid_source;
    check(21, arrays_dimension_expression.or_grid_sum());

    arrays_dimension_expression.or_text = "abcdef";
    check("abcdef", arrays_dimension_expression.or_text);
    check(6, arrays_dimension_expression.or_text_length("abcdef"));

    arrays_dimension_expression.and_array = arrays_dimension_expression.and_source;
    check(3, arrays_dimension_expression.and_array_sum());
    arrays_dimension_expression.and_grid = arrays_dimension_expression.and_grid_source;
    check(10, arrays_dimension_expression.and_grid_sum());

    arrays_dimension_expression.xor_array = arrays_dimension_expression.xor_source;
    check(28, arrays_dimension_expression.xor_array_sum());
    arrays_dimension_expression.xor_grid = arrays_dimension_expression.xor_grid_source;
    check(105, arrays_dimension_expression.xor_grid_sum());

    arrays_dimension_expression.eq_array = arrays_dimension_expression.eq_source;
    check(5, arrays_dimension_expression.eq_array_sum());
    arrays_dimension_expression.eq_grid = arrays_dimension_expression.eq_grid_source;
    check(11, arrays_dimension_expression.eq_grid_sum());

    DimensionHolder holder = new DimensionHolder();
    holder.or_member = arrays_dimension_expression.or_source;
    check(28, arrays_dimension_expression.or_member_sum(holder));
    holder.or_grid_member = arrays_dimension_expression.or_grid_source;
    check(21, arrays_dimension_expression.or_grid_member_sum(holder));
    holder.or_text_member = "abcdef";
    check("abcdef", holder.or_text_member);
  }

  static void check(int expected, int actual) {
    if (expected != actual)
      throw new Exception("expected " + expected + " but got " + actual);
  }

  static void check(string expected, string actual) {
    if (expected != actual)
      throw new Exception("expected " + expected + " but got " + actual);
  }
}
