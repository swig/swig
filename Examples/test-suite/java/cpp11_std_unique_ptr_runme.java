import cpp11_std_unique_ptr.*;

public class cpp11_std_unique_ptr_runme {
  static {
    try {
        System.loadLibrary("cpp11_std_unique_ptr");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void WaitForGC()
  {
    System.gc();
    System.runFinalization();
    try {
      java.lang.Thread.sleep(10);
    } catch (java.lang.InterruptedException e) {
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    Klass k1 = cpp11_std_unique_ptr.makeKlassUniquePtr("first");
    if (!k1.getLabel().equals("first"))
      throw new RuntimeException("wrong object label");

    Klass k2 = cpp11_std_unique_ptr.makeKlassUniquePtr("second");
    if (Klass.getTotal_count() != 2)
      throw new RuntimeException("number of objects should be 2");

    k1 = null;
    {
      int countdown = 500;
      int expectedCount = 1;
      while (true) {
        WaitForGC();
        if (--countdown == 0)
          break;
        if (Klass.getTotal_count() == expectedCount)
          break;
      }
      int actualCount = Klass.getTotal_count();
      if (actualCount != expectedCount)
        System.err.println("GC failed to run (cpp11_std_unique_ptr 1). Expected count: " + expectedCount + " Actual count: " + actualCount); // Finalizers are not guaranteed to be run and sometimes they just don't
    }

    if (!k2.getLabel().equals("second"))
      throw new RuntimeException("wrong object label");

    k2 = null;
    {
      int countdown = 500;
      int expectedCount = 0;
      while (true) {
        WaitForGC();
        if (--countdown == 0)
          break;
        if (Klass.getTotal_count() == expectedCount)
          break;
      };
      int actualCount = Klass.getTotal_count();
      if (actualCount != expectedCount)
        System.err.println("GC failed to run (cpp11_std_unique_ptr 2). Expected count: " + expectedCount + " Actual count: " + actualCount); // Finalizers are not guaranteed to be run and sometimes they just don't
    }
  }
}
