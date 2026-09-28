import cpp11_rvalue_reference.*;

public class cpp11_rvalue_reference_runme {

  static {
    try {
      System.loadLibrary("cpp11_rvalue_reference");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    A a = new A();
    a.setAcopy(5);
    if (a.getAcopy() != 5)
      throw new RuntimeException("getAcopy failed");

    A b = new A();
    b.setAref(new RvalueRefDefault_def().move(a.getAptr()));
    if (b.getAcopy() != 5)
      throw new RuntimeException("RvalueRefDefault move failed");
  }
}
