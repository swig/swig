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
  }
}
