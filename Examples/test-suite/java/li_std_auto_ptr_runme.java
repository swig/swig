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

  // Suppress warning about System.runFinalization() call.
  @SuppressWarnings({"deprecation", "removal"})
  private static void WaitForGC()
  {
    System.gc();
    System.runFinalization();
    try {
      java.lang.Thread.sleep(10);
    } catch (java.lang.InterruptedException e) {
    }
  }

  private static void checkCount(int expected_count) {
    int actual_count = Klass.getTotal_count();
    if (actual_count != expected_count)
      throw new RuntimeException("Counts incorrect, expected:" + expected_count + " actual:" + actual_count);
  }

  public static void main(String argv[]) throws Throwable
  {
    // Test raw pointer handling involving virtual inheritance
    {
      KlassInheritance kini = new KlassInheritance("KlassInheritanceInput");
      checkCount(1);
      String s = li_std_auto_ptr.useKlassRawPtr(kini);
      if (!s.equals("KlassInheritanceInput"))
        throw new RuntimeException("Incorrect string: " + s);
      kini.delete();
      checkCount(0);
    }

    // auto_ptr as input
    {
      Klass kin = new Klass("KlassInput");
      checkCount(1);
      String s = li_std_auto_ptr.takeKlassAutoPtr(kin);
      checkCount(0);
      if (!s.equals("KlassInput"))
        throw new RuntimeException("Incorrect string: " + s);
      if (!li_std_auto_ptr.is_nullptr(kin))
        throw new RuntimeException("is_nullptr failed");
      kin.delete(); // Should not fail, even though already deleted
      checkCount(0);
    }

    {
      Klass kin = new Klass("KlassInput");
      checkCount(1);
      String s = li_std_auto_ptr.takeKlassAutoPtr(kin);
      checkCount(0);
      if (!s.equals("KlassInput"))
        throw new RuntimeException("Incorrect string: " + s);
      if (!li_std_auto_ptr.is_nullptr(kin))
        throw new RuntimeException("is_nullptr failed");
      boolean exception_thrown = false;
      try {
        li_std_auto_ptr.takeKlassAutoPtr(kin);
      } catch (RuntimeException e) {
        if (!e.getMessage().contains("Cannot release ownership as memory is not owned"))
          throw new RuntimeException("incorrect exception message");
        exception_thrown = true;
      }
      if (!exception_thrown)
          throw new RuntimeException("double usage of takeKlassAutoPtr should have been an error");
      kin.delete(); // Should not fail, even though already deleted
      checkCount(0);
    }

    {
      Klass kin = new Klass("KlassInput");
      boolean exception_thrown = false;
      Klass notowned = li_std_auto_ptr.get_not_owned_ptr(kin);
      try {
        li_std_auto_ptr.takeKlassAutoPtr(notowned);
      } catch (RuntimeException e) {
        if (!e.getMessage().contains("Cannot release ownership as memory is not owned"))
          throw new RuntimeException("incorrect exception message");
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new RuntimeException("Should have thrown 'Cannot release ownership as memory is not owned' error");
      checkCount(1);
      kin.delete();
      checkCount(0);
    }

    {
      KlassInheritance kini = new KlassInheritance("KlassInheritanceInput");
      checkCount(1);
      String s = li_std_auto_ptr.takeKlassAutoPtr(kini);
      checkCount(0);
      if (!s.equals("KlassInheritanceInput"))
        throw new RuntimeException("Incorrect string: " + s);
      if (!li_std_auto_ptr.is_nullptr(kini))
        throw new RuntimeException("is_nullptr failed");
      kini.delete(); // Should not fail, even though already deleted
      checkCount(0);
    }

    li_std_auto_ptr.takeKlassAutoPtr(null);
    li_std_auto_ptr.takeKlassAutoPtr(li_std_auto_ptr.make_null());
    checkCount(0);

    // overloaded parameters
    if (li_std_auto_ptr.overloadTest() != 0)
      throw new RuntimeException("overloadTest failed");
    if (li_std_auto_ptr.overloadTest(null) != 1)
      throw new RuntimeException("overloadTest failed");
    if (li_std_auto_ptr.overloadTest(new Klass("over")) != 1)
      throw new RuntimeException("overloadTest failed");
    checkCount(0);


    // auto_ptr as output
    Klass k1 = li_std_auto_ptr.makeKlassAutoPtr("first");
    if (!k1.getLabel().equals("first"))
      throw new RuntimeException("wrong object label");

    Klass k2 = li_std_auto_ptr.makeKlassAutoPtr("second");
    checkCount(2);

    k1.delete();
    k1 = null;
    checkCount(1);

    if (!k2.getLabel().equals("second"))
      throw new RuntimeException("wrong object label");

    k2.delete();
    k2 = null;
    checkCount(0);

    if (li_std_auto_ptr.makeNullAutoPtr() != null)
      throw new RuntimeException("null failure");
  }
}
