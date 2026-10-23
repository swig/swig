import catches.*;

public class catches_runme {

  static {
    try {
      System.loadLibrary("catches");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(RuntimeException e, String expected) {
    if (!e.getMessage().equals(expected))
      throw new RuntimeException("bad exception message: " + e.getMessage());
  }

  public static void main(String argv[]) {
    try {
      catches.test_catches(1);
      throw new Error("missed exception");
    } catch (RuntimeException e) {
      check(e, "C++ int exception thrown, value: 1");
    }
    try {
      catches.test_catches(2);
      throw new Error("missed exception");
    } catch (RuntimeException e) {
      check(e, "two");
    }
    try {
      catches.test_catches(3);
      throw new Error("missed exception");
    } catch (RuntimeException e) {
      check(e, "C++ ThreeException const & exception thrown");
    }

    try {
      catches.test_exception_specification(1);
      throw new Error("missed exception");
    } catch (RuntimeException e) {
      check(e, "C++ int exception thrown, value: 1");
    }
    try {
      catches.test_exception_specification(2);
      throw new Error("missed exception");
    } catch (RuntimeException e) {
      check(e, "unknown exception");
    }
    try {
      catches.test_exception_specification(3);
      throw new Error("missed exception");
    } catch (RuntimeException e) {
      check(e, "unknown exception");
    }

    try {
      catches.test_catches_all(1);
      throw new Error("missed exception");
    } catch (RuntimeException e) {
      check(e, "unknown exception");
    }
  }
}
