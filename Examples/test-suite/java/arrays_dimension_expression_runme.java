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
    // Setting an array sized 'DIM_FLAGS | 4' copies its 7 elements, and no more.
    arrays_dimension_expression.setOr_array(arrays_dimension_expression.getOr_source());
    check(28, arrays_dimension_expression.or_array_sum());

    arrays_dimension_expression.setOr_grid(arrays_dimension_expression.getOr_grid_source());
    check(21, arrays_dimension_expression.or_grid_sum());

    arrays_dimension_expression.setOr_text("abcdef");
    check("abcdef", arrays_dimension_expression.getOr_text());
    check(6, arrays_dimension_expression.or_text_length("abcdef"));

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
