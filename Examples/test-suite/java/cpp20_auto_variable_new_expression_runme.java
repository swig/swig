import cpp20_auto_variable_new_expression.*;

public class cpp20_auto_variable_new_expression_runme {

  static {
    try {
      System.loadLibrary("cpp20_auto_variable_new_expression");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    if (cpp20_auto_variable_new_expression.int_at(cpp20_auto_variable_new_expression.getDeduced_bound(), 2) != 32)
      throw new RuntimeException("deduced_bound");
    if (cpp20_auto_variable_new_expression.int_value(cpp20_auto_variable_new_expression.getConstrained_pointer()) != 33)
      throw new RuntimeException("constrained_pointer");
    if (cpp20_auto_variable_new_expression.int_value(cpp20_auto_variable_new_expression.getConstrained_decorated()) != 34)
      throw new RuntimeException("constrained_decorated");
  }
}
