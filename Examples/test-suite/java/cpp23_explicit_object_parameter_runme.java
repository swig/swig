import cpp23_explicit_object_parameter.*;

public class cpp23_explicit_object_parameter_runme {

  static {
    try {
      System.loadLibrary("cpp23_explicit_object_parameter");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Exception {
    Counter c = new Counter();
    if (c.getValue() != 10)
      throw new RuntimeException("value");

    // The explicit object parameter is the object itself, so each of these takes no arguments.
    if (c.by_lvalue_ref() != 11)
      throw new RuntimeException("by_lvalue_ref()");
    if (c.by_const_ref() != 12)
      throw new RuntimeException("by_const_ref()");
    if (c.by_value() != 13)
      throw new RuntimeException("by_value()");
    if (c.deduced() != 14)
      throw new RuntimeException("deduced()");
    if (c.deduced_trailing() != 15)
      throw new RuntimeException("deduced_trailing()");
    if (c.declared_only() != 17)
      throw new RuntimeException("declared_only()");

    // Only the parameters declared after the explicit object parameter are wrapped.
    if (c.add(1, 2) != 13)
      throw new RuntimeException("add(1, 2)");

    // The wrapped methods really do take no arguments.
    Counter.class.getMethod("by_lvalue_ref");
    Counter.class.getMethod("deduced");
    Counter.class.getMethod("add", int.class, int.class);
    try {
      Counter.class.getMethod("by_lvalue_ref", Counter.class);
      throw new RuntimeException("by_lvalue_ref should take no arguments");
    } catch (NoSuchMethodException expected) {
    }

    // Ordinary and static member functions declared alongside are unaffected.
    if (c.implicit_object() != 18)
      throw new RuntimeException("implicit_object()");
    if (Counter.no_object() != 9)
      throw new RuntimeException("no_object()");

    Chain chain = new Chain();
    if (chain.self_ptr().getValue() != 20)
      throw new RuntimeException("self_ptr()");
  }
}
