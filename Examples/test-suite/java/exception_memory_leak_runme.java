import exception_memory_leak.*;

public class exception_memory_leak_runme {
  static {
    try {
      System.loadLibrary("exception_memory_leak");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }
  public static void main(String argv[]) {
    Foo a = new Foo();
    if (a.get_count() != 1) throw new RuntimeException("Should have 1 Foo objects");

    Foo b = new Foo();
    if (a.get_count() != 2) throw new RuntimeException("Should have 2 Foo objects");

    // Normal behaviour
    exception_memory_leak.trigger_internal_swig_exception("no problem", a);
    if (a.get_count() != 2) throw new RuntimeException("Should have 2 Foo objects");
    if (a.get_freearg_count() != 1) throw new RuntimeException("freearg should have been used once");

    // SWIG exception triggered and handled (return new object case).
    String message = null;
    try {
        exception_memory_leak.trigger_internal_swig_exception("null", b);
    } catch (Throwable t) {
        message = t.getMessage();
    }
    if (!message.equals("Let's see how the bindings manage this exception!")) throw new RuntimeException("Didn't throw the right exception");

    if (a.get_count() != 2) throw new RuntimeException("Should have 2 Foo objects (got " + String.valueOf(a.get_count()) + ")");
    if (a.get_freearg_count() != 2) throw new RuntimeException("freearg should have been used twice");

    // SWIG exception triggered and handled (return by value case).
    message = null;
    try {
        exception_memory_leak.trigger_internal_swig_exception("null", b);
    } catch (Throwable t) {
        message = t.getMessage();
    }
    if (!message.equals("Let's see how the bindings manage this exception!")) throw new RuntimeException("Didn't throw the right exception");

    if (a.get_count() != 2) throw new RuntimeException("Should have 2 Foo objects (got " + String.valueOf(a.get_count()) + ")");
  }
}
