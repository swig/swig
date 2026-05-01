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
    cpp_lambda fn = cpp11_std_function.pass_checker(420);

    // invoke functor via call method
    boolean result = fn.call(420, "Petka");
    if (!result)
      throw new RuntimeException("Petka 420 should be true");

    result = fn.call(419, "Chapai");
    if (result)
      throw new RuntimeException("Chapai 419 should be false");

    // call wrapper
    result = cpp11_std_function.call_function(fn, 420, "Petka");
    if (!result)
      throw new RuntimeException("Petka 420 should be true");

    result = cpp11_std_function.call_function(fn, 419, "Chapai");
    if (result)
      throw new RuntimeException("Chapai 419 should be false");

    // NULL handling
    boolean passed = false;
    try {
      cpp11_std_function.call_function(null, 420, "Petka");
    } catch (RuntimeException e) {
      passed = true;
    }
    if (!passed)
      throw new RuntimeException("call_function accepted invalid argument");
  }
}
