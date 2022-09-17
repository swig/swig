using System;
using li_std_auto_ptrNamespace;

public class li_std_auto_ptr_runme {
    private static void WaitForGC()
    {
        System.GC.Collect(); 
        System.GC.WaitForPendingFinalizers();
        System.Threading.Thread.Sleep(10);
    }

    private static void checkCount(int expected_count)
    {
      int actual_count = Klass.getTotal_count();
      if (actual_count != expected_count)
        throw new ApplicationException("Counts incorrect, expected:" + expected_count + " actual:" + actual_count);
    }

    public static void Main()
    {
        // Test raw pointer handling involving virtual inheritance
        using (KlassInheritance kini = new KlassInheritance("KlassInheritanceInput")) {
          checkCount(1);
          string s = li_std_auto_ptr.useKlassRawPtr(kini);
          if (s != "KlassInheritanceInput")
            throw new ApplicationException("Incorrect string: " + s);
        }
        checkCount(0);

        // auto_ptr as input
        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = li_std_auto_ptr.takeKlassAutoPtr(kin);
          checkCount(0);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!li_std_auto_ptr.is_nullptr(kin))
            throw new ApplicationException("is_nullptr failed");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = li_std_auto_ptr.takeKlassAutoPtr(kin);
          checkCount(0);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!li_std_auto_ptr.is_nullptr(kin))
            throw new ApplicationException("is_nullptr failed");
          bool exception_thrown = false;
          try {
            li_std_auto_ptr.takeKlassAutoPtr(kin);
          } catch (ApplicationException e) {
            if (!e.Message.Contains("Cannot release ownership as memory is not owned"))
              throw new ApplicationException("incorrect exception message");
            exception_thrown = true;
          }
          if (!exception_thrown)
              throw new ApplicationException("double usage of takeKlassAutoPtr should have been an error");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        using (Klass kin = new Klass("KlassInput")) {
            bool exception_thrown = false;
            Klass notowned = li_std_auto_ptr.get_not_owned_ptr(kin);
            try {
              li_std_auto_ptr.takeKlassAutoPtr(notowned);
            } catch (ApplicationException e) {
              if (!e.Message.Contains("Cannot release ownership as memory is not owned"))
                throw new ApplicationException("incorrect exception message");
              exception_thrown = true;
            }
            if (!exception_thrown)
                throw new ApplicationException("Should have thrown 'Cannot release ownership as memory is not owned' error");
            checkCount(1);
        }
        checkCount(0);

        using (KlassInheritance kini = new KlassInheritance("KlassInheritanceInput")) {
          checkCount(1);
          string s = li_std_auto_ptr.takeKlassAutoPtr(kini);
          checkCount(0);
          if (s != "KlassInheritanceInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!li_std_auto_ptr.is_nullptr(kini))
            throw new ApplicationException("is_nullptr failed");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        li_std_auto_ptr.takeKlassAutoPtr(null);
        li_std_auto_ptr.takeKlassAutoPtr(li_std_auto_ptr.make_null());
        checkCount(0);

        // overloaded parameters
        if (li_std_auto_ptr.overloadTest() != 0)
          throw new ApplicationException("overloadTest failed");
        if (li_std_auto_ptr.overloadTest(null) != 1)
          throw new ApplicationException("overloadTest failed");
        if (li_std_auto_ptr.overloadTest(new Klass("over")) != 1)
          throw new ApplicationException("overloadTest failed");
        checkCount(0);


        // auto_ptr as output
        Klass k1 = li_std_auto_ptr.makeKlassAutoPtr("first");
        if (k1.getLabel() != "first")
            throw new Exception("wrong object label");

        Klass k2 = li_std_auto_ptr.makeKlassAutoPtr("second");
        checkCount(2);

        using (Klass k3 = li_std_auto_ptr.makeKlassAutoPtr("second")) {
          checkCount(3);
        }
        checkCount(2);

        k1.Dispose();
        k1 = null;
        checkCount(1);

        if (k2.getLabel() != "second")
            throw new Exception("wrong object label");

        k2.Dispose();
        k2 = null;
        checkCount(0);

        if (li_std_auto_ptr.makeNullAutoPtr() != null)
          throw new Exception("null failure");
    }
}
