import li_std_auto_ptr.*;

public class li_std_auto_ptr_runme {
  static {
    try {
        System.loadLibrary("li_std_auto_ptr");
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
      java.lang.Thread.sleep(1);
    } catch (java.lang.InterruptedException e) {
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    Klass k1 = li_std_auto_ptr.makeKlassAutoPtr("first");
    if (!k1.getLabel().equals("first"))
      throw new RuntimeException("wrong object label");

    Klass k2 = li_std_auto_ptr.makeKlassAutoPtr("second");
    if (Klass.getTotal_count() != 2)
      throw new RuntimeException("number of objects should be 2");

    k1 = null;
    WaitForGC();

    if (Klass.getTotal_count() != 1)
      throw new RuntimeException("number of objects should be 1");

    if (!k2.getLabel().equals("second"))
      throw new RuntimeException("wrong object label");

    k2 = null;
    WaitForGC();

    if (Klass.getTotal_count() != 0)
      throw new RuntimeException("no objects should be left");
  }
}
