import cpp11_using_functor.*;

public class cpp11_using_functor_runme {

  static {
    try {
      System.loadLibrary("cpp11_using_functor");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Overloaded helper built from two concrete functor base classes (C++11 form).
    // operator() is renamed to call() by %rename, giving an overloaded proxy method.
    OverloadedIntDouble ov = new OverloadedIntDouble();
    if (!ov.call(7).equals("Int:7"))
      throw new RuntimeException("ov.call(7)");
    if (!ov.call(2.5).equals("Double:2.500000"))
      throw new RuntimeException("ov.call(2.5)");
  }
}
