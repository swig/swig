import swig_exception_default.*;

public class swig_exception_default_runme {

  static {
    try {
      System.loadLibrary("swig_exception_default");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    if (swig_exception_default.positive_only(1) != 1)
      throw new RuntimeException("positive_only(1) failed");
    try {
      swig_exception_default.positive_only(0);
      throw new RuntimeException("positive_only(0) did not throw");
    } catch (IllegalArgumentException e) {
    }

    if (swig_exception_default.positive_result(1) != 1)
      throw new RuntimeException("positive_result(1) failed");
    try {
      swig_exception_default.positive_result(0);
      throw new RuntimeException("positive_result(0) did not throw");
    } catch (IllegalArgumentException e) {
    }
  }
}
