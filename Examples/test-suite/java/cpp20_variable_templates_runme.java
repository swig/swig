
import cpp20_variable_templates.*;

public class cpp20_variable_templates_runme {

  static {
    try {
      System.loadLibrary("cpp20_variable_templates");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // int satisfies 't + t', NotAddable doesn't.
    if (!cpp20_variable_templates.getAddable_int())
      throw new RuntimeException("addable_int");
    if (cpp20_variable_templates.getAddable_notaddable())
      throw new RuntimeException("addable_notaddable");
  }
}
