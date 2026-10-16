import c99_parameter_array_declarators.*;

public class c99_parameter_array_declarators_runme {

  static {
    try {
      System.loadLibrary("c99_parameter_array_declarators");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // A string is copied into a variable length char array of the size given at runtime
    if (c99_parameter_array_declarators.char_length(5, "abc") != 3)
      throw new RuntimeException("char_length(5, \"abc\") failed");
    try {
      c99_parameter_array_declarators.char_length(3, "abc");
      throw new RuntimeException("char_length(3, \"abc\") should fail as the string is too long");
    } catch (IllegalArgumentException e) {
    }
  }
}
