
import cpp14_variable_templates.*;

public class cpp14_variable_templates_runme {

  static {
    try {
      System.loadLibrary("cpp14_variable_templates");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Variable template instantiations are wrapped as read only variables holding the value
    if (cpp14_variable_templates.getBits_in_char() != 8)
      throw new RuntimeException("bits_in_char");
    if (cpp14_variable_templates.getFactorial_5() != 120)
      throw new RuntimeException("factorial_5");
    if (cpp14_variable_templates.getFactorial_10() != 3628800)
      throw new RuntimeException("factorial_10");
  }
}
