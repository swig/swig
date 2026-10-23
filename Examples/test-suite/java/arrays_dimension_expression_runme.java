import arrays_dimension_expression.*;

public class arrays_dimension_expression_runme {
  static {
    try {
        System.loadLibrary("arrays_dimension_expression");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    // Setting an array with a dimension such as 'DIM_FLAGS | 4' copies all of its elements, and no more.
    arrays_dimension_expression.setOr_array(arrays_dimension_expression.getOr_source());
    check(28, arrays_dimension_expression.or_array_sum());

    arrays_dimension_expression.setOr_grid(arrays_dimension_expression.getOr_grid_source());
    check(21, arrays_dimension_expression.or_grid_sum());

    arrays_dimension_expression.setOr_text("abcdef");
    check("abcdef", arrays_dimension_expression.getOr_text());
    check(6, arrays_dimension_expression.or_text_length("abcdef"));

    arrays_dimension_expression.setAnd_array(arrays_dimension_expression.getAnd_source());
    check(3, arrays_dimension_expression.and_array_sum());
    arrays_dimension_expression.setAnd_grid(arrays_dimension_expression.getAnd_grid_source());
    check(10, arrays_dimension_expression.and_grid_sum());

    arrays_dimension_expression.setXor_array(arrays_dimension_expression.getXor_source());
    check(28, arrays_dimension_expression.xor_array_sum());
    arrays_dimension_expression.setXor_grid(arrays_dimension_expression.getXor_grid_source());
    check(105, arrays_dimension_expression.xor_grid_sum());

    arrays_dimension_expression.setEq_array(arrays_dimension_expression.getEq_source());
    check(5, arrays_dimension_expression.eq_array_sum());
    arrays_dimension_expression.setEq_grid(arrays_dimension_expression.getEq_grid_source());
    check(11, arrays_dimension_expression.eq_grid_sum());

    DimensionHolder holder = new DimensionHolder();
    holder.setOr_member(arrays_dimension_expression.getOr_source());
    check(28, arrays_dimension_expression.or_member_sum(holder));
    holder.setOr_grid_member(arrays_dimension_expression.getOr_grid_source());
    check(21, arrays_dimension_expression.or_grid_member_sum(holder));
    holder.setOr_text_member("abcdef");
    check("abcdef", holder.getOr_text_member());
  }

  static void check(int expected, int actual) {
    if (expected != actual)
      throw new RuntimeException("expected " + expected + " but got " + actual);
  }

  static void check(String expected, String actual) {
    if (!expected.equals(actual))
      throw new RuntimeException("expected " + expected + " but got " + actual);
  }
}
