import li_std_optional.*;

public class li_std_optional_runme {

  static {
    try {
      System.loadLibrary("li_std_optional");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    // Test make_optional with value
    OptionalInt v = li_std_optional.make_optional(42);

    // Test make_empty_optional
    OptionalInt e = li_std_optional.make_empty_optional();

    // Test optional_value_or with value
    int r1 = li_std_optional.optional_value_or(li_std_optional.make_optional(10), 99);
    if (r1 != 10)
      throw new RuntimeException("optional_value_or with value test failed: " + r1);

    // Test optional_value_or with empty
    int r2 = li_std_optional.optional_value_or(li_std_optional.make_empty_optional(), 99);
    if (r2 != 99)
      throw new RuntimeException("optional_value_or with empty test failed: " + r2);
  }
}
