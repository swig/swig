import cpp20_abbreviated_template_overloads.*;

public class cpp20_abbreviated_template_overloads_runme {

  static {
    try {
      System.loadLibrary("cpp20_abbreviated_template_overloads");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Two instantiations of one abbreviated function template sharing a name are overloads.
    if (cpp20_abbreviated_template_overloads.scaled(3) != 30)
      throw new RuntimeException("scaled(3)");
    if (cpp20_abbreviated_template_overloads.scaled(2.5) != 25)
      throw new RuntimeException("scaled(2.5)");

    // %ignore on the Integral overload leaves the FloatingPoint one, which halves rather than increments.
    if (cpp20_abbreviated_template_overloads.classify_double(5.0) != 2.5)
      throw new RuntimeException("classify_double(5.0)");

    // %ignore on the FloatingPoint overload leaves the Integral one.
    if (cpp20_abbreviated_template_overloads.pick_int(5) != 6)
      throw new RuntimeException("pick_int(5)");
  }
}
