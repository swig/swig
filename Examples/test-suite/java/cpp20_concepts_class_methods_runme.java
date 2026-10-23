import cpp20_concepts_class_methods.*;

public class cpp20_concepts_class_methods_runme {

  static {
    try {
      System.loadLibrary("cpp20_concepts_class_methods");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Calculator c = new Calculator();

    // Trailing requires-clause on a member function template.
    if (c.cube_int(3) != 27)
      throw new RuntimeException("cube_int(3)");
    if (c.cube_int(-4) != -64)
      throw new RuntimeException("cube_int(-4)");
    if (c.cube_double(2.0) != 8.0)
      throw new RuntimeException("cube_double(2.0)");

    // Prefix requires-clause on a member function template.
    if (c.quad_int(2) != 16)
      throw new RuntimeException("quad_int(2)");
    if (c.quad_int(-3) != 81)
      throw new RuntimeException("quad_int(-3)");

    // Static member function template constrained by an inline requires-expression.
    if (Calculator.sum_int(2, 3) != 5)
      throw new RuntimeException("Calculator.sum_int(2, 3)");
    if (Calculator.sum_int(-7, 4) != -3)
      throw new RuntimeException("Calculator.sum_int(-7, 4)");

    // Member function template constrained by a named concept whose body is itself a requires-expression.
    if (c.addn_int(7, 4) != 11)
      throw new RuntimeException("addn_int(7, 4)");
    if (c.addn_int(-2, 5) != 3)
      throw new RuntimeException("addn_int(-2, 5)");

    // Member function template with two template parameters and a compound constraint joined by '&&'.
    if (c.scale_int_int(5, 3) != 15)
      throw new RuntimeException("scale_int_int(5, 3)");
    if (c.scale_int_int(-4, 2) != -8)
      throw new RuntimeException("scale_int_int(-4, 2)");
  }
}
