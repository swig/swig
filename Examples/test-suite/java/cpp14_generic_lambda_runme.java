import cpp14_generic_lambda.*;

public class cpp14_generic_lambda_runme {

  static {
    try {
      System.loadLibrary("cpp14_generic_lambda");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Single auto parameter.
    if (cpp14_generic_lambda.run_twice(5) != 10)
      throw new RuntimeException("run_twice(5)");

    // Two auto parameters.
    if (cpp14_generic_lambda.run_add(3, 4) != 7)
      throw new RuntimeException("run_add(3, 4)");

    // 'auto' placeholder as the explicit trailing return type.
    if (cpp14_generic_lambda.run_negate_value(5) != -5)
      throw new RuntimeException("run_negate_value(5)");
    if (cpp14_generic_lambda.run_halve(9) != 4)
      throw new RuntimeException("run_halve(9)");
    if (cpp14_generic_lambda.run_quarter(9) != 2)
      throw new RuntimeException("run_quarter(9)");
    if (cpp14_generic_lambda.run_reference_thing() != 7)
      throw new RuntimeException("run_reference_thing()");
    if (cpp14_generic_lambda.run_address_of_thing() != 7)
      throw new RuntimeException("run_address_of_thing()");
  }
}
