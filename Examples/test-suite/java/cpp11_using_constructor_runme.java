
import cpp11_using_constructor.*;

public class cpp11_using_constructor_runme {

  static {
    try {
	System.loadLibrary("cpp11_using_constructor");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Public base constructors
    new PublicDerived1(0, "hi").meth();
    new PublicDerived2().meth();
    new PublicDerived2(0, "hi").meth();
    new PublicDerived3().meth();
    new PublicDerived3(0, "hi").meth();
    new PublicDerived4().meth();

    // Protected base constructors
    // Cannot test these as the constructors are protected
  }
}
