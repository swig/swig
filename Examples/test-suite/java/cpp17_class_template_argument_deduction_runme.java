import cpp17_class_template_argument_deduction.*;

public class cpp17_class_template_argument_deduction_runme {

  static {
    try {
      System.loadLibrary("cpp17_class_template_argument_deduction");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // The CTAD variables 'ov' and 'bx' are skipped (Warning 347); declarations alongside them wrap.
    if (cpp17_class_template_argument_deduction.unaffected(41) != 42)
      throw new RuntimeException("unaffected(41)");

    // The deduction guides emit nothing; a declaration following them still wraps.
    if (cpp17_class_template_argument_deduction.after_guides(40) != 42)
      throw new RuntimeException("after_guides(40)");
  }
}
