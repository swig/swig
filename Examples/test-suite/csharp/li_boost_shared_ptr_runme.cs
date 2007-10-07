using System;
using li_boost_shared_ptrNamespace;

public class runme
{
  // Debugging flag
  public static bool debug = false;

  static void Main() 
  {
    if (debug)
      Console.WriteLine("Started");

    li_boost_shared_ptr.debug_shared=debug;

    const int loopCount = 1;
    for (int i=0; i<loopCount; i++) {
      new runme().runtest();
      System.GC.Collect(); 
      System.GC.WaitForPendingFinalizers();
      if (i%100 == 0) {
//        Console.WriteLine("i: {0} {1}", i, Klass.getTotal_count());
        System.Threading.Thread.Sleep(10);
      }
    }

    if (debug)
      Console.WriteLine("Nearly finished");

    int countdown = 100;
    while (true) {
      System.GC.Collect(); 
      System.GC.WaitForPendingFinalizers();
      System.Threading.Thread.Sleep(100);
      if (--countdown == 0)
        break;
      if (Klass.getTotal_count() == 0)
        break;
      else
        Console.WriteLine("Count: {0}", Klass.getTotal_count());
    };
    if (Klass.getTotal_count() != 0)
      throw new ApplicationException("Klass.total_count=" + Klass.getTotal_count());

    if (debug)
      Console.WriteLine("Finished");
  }

  private void runtest() {
    // simple shared_ptr usage - created in C++
    {
      Klass k = new Klass("me oh my");
      String val = k.getValue();
      verifyValue("me oh my", val);
      verifyCount(1, k);
    }

    // simple shared_ptr usage - not created in C++
    {
      Klass k = li_boost_shared_ptr.factorycreate();
      String val = k.getValue();
      verifyValue("factorycreate", val);
      verifyCount(1, k);
    }

    // pass by shared_ptr
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.smartpointertest(k);
      String val = kret.getValue();
      verifyValue("me oh my smartpointertest", val);
      verifyCount(2, k);
      verifyCount(2, kret);
    }

    // pass by shared_ptr pointer
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.smartpointerpointertest(k);
      String val = kret.getValue();
      verifyValue("me oh my smartpointerpointertest", val);
      verifyCount(2, k);
      verifyCount(2, kret);
    }

    // pass by shared_ptr reference
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.smartpointerreftest(k);
      String val = kret.getValue();
      verifyValue("me oh my smartpointerreftest", val);
      verifyCount(2, k);
      verifyCount(2, kret);
    }

    // pass by shared_ptr pointer reference
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.smartpointerpointerreftest(k);
      String val = kret.getValue();
      verifyValue("me oh my smartpointerpointerreftest", val);
      verifyCount(2, k);
      verifyCount(2, kret);
    }

    // const pass by shared_ptr
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.constsmartpointertest(k);
      String val = kret.getValue();
      verifyValue("me oh my", val);
      verifyCount(2, k);
      verifyCount(2, kret);
    }

    // const pass by shared_ptr pointer
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.constsmartpointerpointertest(k);
      String val = kret.getValue();
      verifyValue("me oh my", val);
      verifyCount(2, k);
      verifyCount(2, kret);
    }

    // const pass by shared_ptr reference
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.constsmartpointerreftest(k);
      String val = kret.getValue();
      verifyValue("me oh my", val);
      verifyCount(2, k);
      verifyCount(2, kret);
    }

    // pass by value
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.valuetest(k);
      String val = kret.getValue();
      verifyValue("me oh my valuetest", val);
      verifyCount(1, k);
      verifyCount(1, kret);
    }

    // pass by pointer
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.pointertest(k);
      String val = kret.getValue();
      verifyValue("me oh my pointertest", val);
      verifyCount(1, k);
      verifyCount(1, kret);
    }

    // pass by reference
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.reftest(k);
      String val = kret.getValue();
      verifyValue("me oh my reftest", val);
      verifyCount(1, k);
      verifyCount(1, kret);
    }

    // pass by pointer reference
    {
      Klass k = new Klass("me oh my");
      Klass kret = li_boost_shared_ptr.pointerreftest(k);
      String val = kret.getValue();
      verifyValue("me oh my pointerreftest", val);
      verifyCount(1, k);
      verifyCount(1, kret);
    }

    // null tests
    {
      Klass k = null;

      // TODO: add in const versions too
      if (li_boost_shared_ptr.smartpointertest(k) != null)
        throw new ApplicationException("return was not null");

      if (li_boost_shared_ptr.smartpointerpointertest(k) != null)
        throw new ApplicationException("return was not null");

      if (li_boost_shared_ptr.smartpointerreftest(k) != null)
        throw new ApplicationException("return was not null");

      if (li_boost_shared_ptr.smartpointerpointerreftest(k) != null)
        throw new ApplicationException("return was not null");

      if (li_boost_shared_ptr.nullsmartpointerpointertest(null) != "null pointer")
        throw new ApplicationException("not null smartpointer pointer");

      try { li_boost_shared_ptr.valuetest(k); throw new ApplicationException("Failed to catch null pointer"); } catch (ArgumentNullException) {}

      if (li_boost_shared_ptr.pointertest(k) != null)
        throw new ApplicationException("return was not null");

      try { li_boost_shared_ptr.reftest(k); throw new ApplicationException("Failed to catch null pointer"); } catch (ArgumentNullException) {}
    }

    // $owner
    {
      Klass k = li_boost_shared_ptr.pointerownertest();
      String val = k.getValue();
      verifyValue("pointerownertest", val);
      verifyCount(1, k);
    }
    {
      Klass k = li_boost_shared_ptr.smartpointerpointerownertest();
      String val = k.getValue();
      verifyValue("smartpointerpointerownertest", val);
      verifyCount(1, k);
    }

    ////////////////////////////////// Derived classes ////////////////////////////////////////
    // derived pass by pointer
    {
      KlassDerived k = new KlassDerived("me oh my");
      KlassDerived kret = li_boost_shared_ptr.derivedpointertest(k);
      String val = kret.getValue();
      verifyValue("me oh my derivedpointertest-Derived", val);
      verifyCount(2, k); // includes an extra reference for the upcast
      verifyCount(2, kret);
    }


    // Member variables
    // smart pointer by value
    {
      MemberVariables m = new MemberVariables();
      Klass k = new Klass("smart member value");
      m.SmartMemberValue = k;
      String val = k.getValue();
      verifyValue("smart member value", val);
      verifyCount(2, k);

      Klass kmember = m.SmartMemberValue;
      val = kmember.getValue();
      verifyValue("smart member value", val);
      verifyCount(3, kmember);
      verifyCount(3, k);

      m.Dispose();
      verifyCount(2, kmember);
      verifyCount(2, k);
    }
    // smart pointer by pointer
    {
      MemberVariables m = new MemberVariables();
      Klass k = new Klass("smart member pointer");
      m.SmartMemberPointer = k;
      String val = k.getValue();
      verifyValue("smart member pointer", val);
      verifyCount(1, k);

      Klass kmember = m.SmartMemberPointer;
      val = kmember.getValue();
      verifyValue("smart member pointer", val);
      verifyCount(2, kmember);
      verifyCount(2, k);

      m.Dispose();
      verifyCount(2, kmember);
      verifyCount(2, k);
    }
    // smart pointer by reference
    {
      MemberVariables m = new MemberVariables();
      Klass k = new Klass("smart member reference");
      m.SmartMemberReference = k;
      String val = k.getValue();
      verifyValue("smart member reference", val);
      verifyCount(2, k);

      Klass kmember = m.SmartMemberReference;
      val = kmember.getValue();
      verifyValue("smart member reference", val);
      verifyCount(3, kmember);
      verifyCount(3, k);

      // The C++ reference refers to SmartMemberValue...
      Klass kmemberVal = m.SmartMemberValue;
      val = kmember.getValue();
      verifyValue("smart member reference", val);
      verifyCount(4, kmemberVal);
      verifyCount(4, kmember);
      verifyCount(4, k);

      m.Dispose();
      verifyCount(3, kmember);
      verifyCount(3, k);
    }
    // plain by value
    {
      MemberVariables m = new MemberVariables();
      Klass k = new Klass("plain member value");
      m.MemberValue = k;
      String val = k.getValue();
      verifyValue("plain member value", val);
      verifyCount(1, k);

      Klass kmember = m.MemberValue;
      val = kmember.getValue();
      verifyValue("plain member value", val);
      verifyCount(1, kmember);
      verifyCount(1, k);

      m.Dispose();
      verifyCount(1, kmember);
      verifyCount(1, k);
    }
    // plain by pointer
    {
      MemberVariables m = new MemberVariables();
      Klass k = new Klass("plain member pointer");
      m.MemberPointer = k;
      String val = k.getValue();
      verifyValue("plain member pointer", val);
      verifyCount(1, k);

      Klass kmember = m.MemberPointer;
      val = kmember.getValue();
      verifyValue("plain member pointer", val);
      verifyCount(1, kmember);
      verifyCount(1, k);

      m.Dispose();
      verifyCount(1, kmember);
      verifyCount(1, k);
    }
    // plain by reference
    {
      MemberVariables m = new MemberVariables();
      Klass k = new Klass("plain member reference");
      m.MemberReference = k;
      String val = k.getValue();
      verifyValue("plain member reference", val);
      verifyCount(1, k);

      Klass kmember = m.MemberReference;
      val = kmember.getValue();
      verifyValue("plain member reference", val);
      verifyCount(1, kmember);
      verifyCount(1, k);

      m.Dispose();
      verifyCount(1, kmember);
      verifyCount(1, k);
    }

    // null member variables
    {
      MemberVariables m = new MemberVariables();

      // shared_ptr by value
      Klass k = m.SmartMemberValue;
      if (k != null)
        throw new ApplicationException("expected null");
      m.SmartMemberValue = null;
      k = m.SmartMemberValue;
      if (k != null)
        throw new ApplicationException("expected null");
      verifyCount(0, k);

      // plain by value
      try { m.MemberValue = null; throw new ApplicationException("Failed to catch null pointer"); } catch (ArgumentNullException) {}
    }

  }
  private void verifyValue(String expected, String got) {
    if (expected != got)
      throw new Exception("verify value failed. Expected: " + expected + " Got: " + got);
  }
  private void verifyCount(int expected, Klass k) {
    int got = li_boost_shared_ptr.use_count(k); 
    if (expected != got)
      throw new Exception("verify use_count failed. Expected: " + expected + " Got: " + got);
  }
}
