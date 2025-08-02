
import using_extend_flatten.*;

public class using_extend_flatten_runme {

  static {
    try {
	System.loadLibrary("using_extend_flatten");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    ExtendDerived ed = new ExtendDerived();
    ed.one();
    ed.two();
    ed.three();
  }
}
