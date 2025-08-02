import string_constants.*;

public class string_constants_runme {
  static {
    try {
      System.loadLibrary("string_constants");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    if (!string_constants.ES1.equals(""))
      throw new RuntimeException("fail");
    if (!string_constants.ES2.equals(""))
      throw new RuntimeException("fail");
    if (!string_constants.ZS1.equals("\000"))
      throw new RuntimeException("fail");
    if (!string_constants.ZS2.equals("\000"))
      throw new RuntimeException("fail");
  }
}
