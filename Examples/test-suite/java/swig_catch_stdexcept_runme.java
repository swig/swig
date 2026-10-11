import swig_catch_stdexcept.*;

public class swig_catch_stdexcept_runme {

  static {
    try {
      System.loadLibrary("swig_catch_stdexcept");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    try {
      swig_catch_stdexcept.throw_invalid_argument();
      throw new RuntimeException("throw_invalid_argument failed");
    } catch (IllegalArgumentException e) {
    }
    try {
      swig_catch_stdexcept.throw_out_of_range();
      throw new RuntimeException("throw_out_of_range failed");
    } catch (IndexOutOfBoundsException e) {
    }
    try {
      swig_catch_stdexcept.throw_bad_cast();
      throw new RuntimeException("throw_bad_cast failed");
    } catch (IllegalArgumentException e) {
    }
    try {
      swig_catch_stdexcept.throw_int();
      throw new RuntimeException("throw_int failed");
    } catch (UnknownError e) {
    }
  }
}
