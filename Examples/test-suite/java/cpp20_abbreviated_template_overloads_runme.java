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
  }
}
