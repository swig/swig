import cpp20_abbreviated_template.*;

public class cpp20_abbreviated_template_runme {

  static {
    try {
      System.loadLibrary("cpp20_abbreviated_template");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Single auto parameter.
    if (cpp20_abbreviated_template.twice_int(5) != 10)
      throw new RuntimeException("twice_int(5)");
    if (cpp20_abbreviated_template.twice_short((short)7) != 14)
      throw new RuntimeException("twice_short(7)");

    // Two auto parameters with mixed types (int * double => double).
    if (cpp20_abbreviated_template.scale_id(3, 2.5) != 7.5)
      throw new RuntimeException("scale_id(3, 2.5)");

    // Three auto parameters.
    if (cpp20_abbreviated_template.sum3_iii(1, 2, 3) != 6)
      throw new RuntimeException("sum3_iii(1, 2, 3)");

    // Unnamed auto parameter.
    if (cpp20_abbreviated_template.unnamed_auto_int(99) != 42)
      throw new RuntimeException("unnamed_auto_int(99)");

    // Constrained auto.
    if (cpp20_abbreviated_template.twice_numeric_int(7) != 14)
      throw new RuntimeException("twice_numeric_int(7)");

    // Mixed type-constraints.
    if (cpp20_abbreviated_template.scale_mixed_id(3, 2.5) != 7.5)
      throw new RuntimeException("scale_mixed_id(3, 2.5)");

    // Same type-constraint on multiple parms.
    if (cpp20_abbreviated_template.add_same_int(4, 5) != 9)
      throw new RuntimeException("add_same_int(4, 5)");

    // Unnamed constrained auto.
    if (cpp20_abbreviated_template.unnamed_constrained_int(99) != 42)
      throw new RuntimeException("unnamed_constrained_int(99)");

    // Constrained auto return type with explicit trailing return type.
    if (cpp20_abbreviated_template.half(10) != 5)
      throw new RuntimeException("half(10)");
    if (cpp20_abbreviated_template.cube_constrained_int(3) != 27)
      throw new RuntimeException("cube_constrained_int(3)");

    // Plain auto return type + constrained auto parameter + trailing return type.
    if (cpp20_abbreviated_template.twice_n_arrow_int(7) != 14)
      throw new RuntimeException("twice_n_arrow_int(7)");

    // Constrained 'Numeric auto' return without a trailing return type - SWIG cannot deduce so the function is ignored.
    try {
      cpp20_abbreviated_template.class.getMethod("half_numeric", int.class);
      throw new RuntimeException("half_numeric should be ignored (deduced return type)");
    } catch (NoSuchMethodException expected) {
    }
  }
}
