import private_assign.*;

public class private_assign_runme {

  static {
    try {
	System.loadLibrary("private_assign");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Three three = new Three();
    TwoNotAssignableCopyable tn = three.getTwoNot();
    TwoIsAssignableCopyable ti = three.getTwoIs();
    three.setTwoIs(new TwoIsAssignableCopyable());
  }
}
