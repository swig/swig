import char_constant.*;

public class char_constant_runme {

  static {
    try {
	System.loadLibrary("char_constant");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    if (char_constant.CHAR_CONSTANT != 'x')
      throw new RuntimeException("Invalid value for CHAR_CONSTANT.");
    if (!char_constant.STRING_CONSTANT.equals("xyzzy"))
      throw new RuntimeException("Invalid value for STRING_CONSTANT.");
    if (char_constant.getIa() != 97)
      throw new RuntimeException("Invalid value for ia.");
    if (char_constant.getIb() != 98)
      throw new RuntimeException("Invalid value for ib.");
    if (char_constant.getIparen() != ';')
      throw new RuntimeException("Invalid value for iparen.");
  }
}
