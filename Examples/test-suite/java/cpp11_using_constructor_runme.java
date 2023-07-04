
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

    // Mix of public and overloaded constructors
    new MixedDerived1a(0, "hi").meth();
    new MixedDerived1a().meth();
    new MixedDerived1b(0, "hi").meth();
    new MixedDerived1b().meth();

    new MixedDerived2a(0, "hi").meth();
    new MixedDerived2a().meth();
    new MixedDerived2b(0, "hi").meth();
    new MixedDerived2b().meth();

    new MixedDerived2c(0, "hi").meth();
    new MixedDerived2c().meth();
    new MixedDerived2c(0).meth();

    new MixedDerived2d(0, "hi").meth();
    new MixedDerived2d().meth();
    new MixedDerived2d(0).meth();

    new MixedDerived3a(0, "hi").meth();
    new MixedDerived3a().meth();
    new MixedDerived3b(0, "hi").meth();
    new MixedDerived3b().meth();

    new MixedDerived3c(0, "hi").meth();
    new MixedDerived3c().meth();
    new MixedDerived3c(0).meth();

    new MixedDerived3d(0, "hi").meth();
    new MixedDerived3d().meth();
    new MixedDerived3d(0).meth();

    // Mix of protected base constructors and overloading
    new ProotDerived1a().meth();

    new ProotDerived1b(0, "hi").meth();
    new ProotDerived1b().meth();

    new ProotDerived1c(0, "hi").meth();
    new ProotDerived1c().meth();

    new ProotDerived1d(0).meth();
    new ProotDerived1d().meth();

    new ProotDerived1e(0).meth();
    new ProotDerived1e().meth();

    new ProotDerived2a(0, "hi").meth();

    new ProotDerived2b(0, "hi").meth();

    new ProotDerived2c(0, "hi").meth();
    new ProotDerived2c().meth();

    new ProotDerived2d(0, "hi").meth();
    new ProotDerived2d().meth();

    new ProotDerived2e(0, "hi").meth();
    new ProotDerived2e().meth();

    new ProotDerived2f(0, "hi").meth();
    new ProotDerived2f().meth();
    new ProotDerived2f(0).meth();

    // Missing base
    new HiddenDerived1();
  }
}
