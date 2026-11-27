import cpp11_rvalue_reference3.*;

public class cpp11_rvalue_reference3_runme {

  static {
    try {
      System.loadLibrary("cpp11_rvalue_reference3");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    if (cpp11_rvalue_reference3.funcref_takeit1(cpp11_rvalue_reference3.FUNCREF_DOUBLE, 3) != 6)
      throw new RuntimeException("funcref_takeit1 FUNCREF_DOUBLE failed");
    if (cpp11_rvalue_reference3.funcref_takeit2(cpp11_rvalue_reference3.FUNCREF_DOUBLE, 4) != 8)
      throw new RuntimeException("funcref_takeit2 FUNCREF_DOUBLE failed");
    if (cpp11_rvalue_reference3.funcref_takeit1(cpp11_rvalue_reference3.funcref_returnit1(), 5) != 10)
      throw new RuntimeException("funcref_takeit1 funcref_returnit1 failed");
    if (cpp11_rvalue_reference3.funcref_takeit2(cpp11_rvalue_reference3.funcref_returnit2(), 6) != 12)
      throw new RuntimeException("funcref_takeit2 funcref_returnit2 failed");

    boolean caught = false;
    try {
      cpp11_rvalue_reference3.funcref_takeit1(null, 1);
    } catch (NullPointerException e) {
      caught = true;
    }
    if (!caught)
      throw new RuntimeException("funcref_takeit1 null failed");
  }
}
