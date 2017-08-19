
import cpp11_ref_qualifiers.*;

public class cpp11_ref_qualifiers_runme {

  static {
    try {
      System.loadLibrary("cpp11_ref_qualifiers");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Host h = new Host();
    h.h1();
    h.h2();
    h.h();
  }
}

