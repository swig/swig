
import using_method_typedefs.*;

public class using_method_typedefs_runme {

  static {
    try {
        System.loadLibrary("using_method_typedefs");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(String actual, String expected) {
    if (!actual.equals(expected))
      throw new RuntimeException("expected '" + expected + "' but got '" + actual + "'");
  }

  public static void main(String argv[]) {
    // A protected base method brought into the derived public interface via a using declaration whose
    // qualifier names the base through various typedef forms (issue #2951 typedef coverage, for members).
    check(new UseDirect().testmethod("5"), "Base:5");
    check(new UseTypedef().testmethod("5"), "Base:5");
    check(new UseTypedefChain().testmethod("5"), "Base:5");
    check(new UseTemplateTypedef().testmethod("5"), "TBase:5");
    check(new UseTemplateArgTypedef().testmethod("5"), "TBase:5");
    check(new UseQualified().testmethod("5"), "Ns:5");
    check(new UseNsChain().testmethod("5"), "Ns:5");
  }
}
