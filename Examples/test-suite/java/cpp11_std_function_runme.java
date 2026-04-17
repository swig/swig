import cpp11_std_function.*;

public class cpp11_std_function_runme {

  static {
    try {
        System.loadLibrary("cpp11_std_function");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    cpp_function_string_int_const_string fn = (cpp11_std_function.return_function(420));

    String r = cpp11_std_function.call_function(fn, 420, "Petka");
    if (!r.equals("Petka passed the test"))
      throw new RuntimeException("failed function call");

    boolean passed = false;
    try {
      cpp11_std_function.call_function(null, 420, "Petka");
    } catch (RuntimeException e) {
      passed = true;
    }
    if (!passed)
      throw new RuntimeException("call_function accepted invalid argument");


    passed = false;
    try {
      cpp11_std_function.call_function(fn, 419, "Chapai");
    } catch (RuntimeException e) {
      passed = true;
    }
    if (!passed)
      throw new RuntimeException("call_function did not throw");
  }
}
