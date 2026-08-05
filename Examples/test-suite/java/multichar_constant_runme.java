import multichar_constant.*;

public class multichar_constant_runme {

  static {
    try {
	System.loadLibrary("multichar_constant");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Multicharacter constants have type int, not char.
    if (multichar_constant.MULTICHAR_AB != multichar_constant.getImulti_ab())
      throw new RuntimeException("Invalid value for MULTICHAR_AB.");
  }
}
