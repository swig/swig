
import cpp11_ref_qualifiers_rvalue_unignore.*;

public class cpp11_ref_qualifiers_rvalue_unignore_runme {

  static {
    try {
      System.loadLibrary("cpp11_ref_qualifiers_rvalue_unignore");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    new RefQualifier().m1();
    new RefQualifier().m2();
  }
}

