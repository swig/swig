import cpp0x_lambda_functions.*;

public class cpp0x_lambda_functions_runme {

  static {
    try {
        System.loadLibrary("cpp0x_lambda_functions");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(int received, int expected) {
    if (expected != received)
      throw new RuntimeException("check failed, expected: " + expected + " received: " + received);
  }

  public static void main(String argv[])
  {
    check(cpp0x_lambda_functions.runLambda1(), 11);
    check(cpp0x_lambda_functions.runLambda2(), 11);
    check(cpp0x_lambda_functions.runLambda3(), 11);
    check(cpp0x_lambda_functions.runLambda4(), 11);
    check(cpp0x_lambda_functions.runLambda5(), 1);
    check(cpp0x_lambda_functions.runLambda5(), 2);
  }
}
