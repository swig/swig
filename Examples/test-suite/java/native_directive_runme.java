import native_directive.*;

public class native_directive_runme {

  static {
    try {
	System.loadLibrary("native_directive");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    String s = "abc.DEF-123";
    if (native_directive.CountAlphas(s) != 6)
      throw new RuntimeException("CountAlphas failed");
    if (native_directive.CountAlphaCharacters(s) != 6)
      throw new RuntimeException("CountAlphaCharacters failed");
  }
}

