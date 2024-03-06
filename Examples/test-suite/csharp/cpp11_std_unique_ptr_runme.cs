using System;
using cpp11_std_unique_ptrNamespace;

public class cpp11_std_unique_ptr_runme {
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
          string s = cpp11_std_unique_ptr.useKlassRawPtr(kini);
          if (s != "KlassInheritanceInput")
            throw new ApplicationException("Incorrect string: " + s);
        }
        checkCount(0);


        ///// INPUT BY VALUE /////
        // unique_ptr as input
        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin);
          checkCount(0);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw new ApplicationException("is_nullptr failed");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin);
          checkCount(0);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw new ApplicationException("is_nullptr failed");
          bool exception_thrown = false;
          try {
            cpp11_std_unique_ptr.takeKlassUniquePtr(kin);
          } catch (ApplicationException e) {
            if (!e.Message.Contains("Cannot release ownership as memory is not owned"))
              throw new ApplicationException("incorrect exception message");
            exception_thrown = true;
          }
          if (!exception_thrown)
              throw new ApplicationException("double usage of takeKlassUniquePtr should have been an error");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        using (Klass kin = new Klass("KlassInput")) {
            bool exception_thrown = false;
            Klass notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin);
            try {
              cpp11_std_unique_ptr.takeKlassUniquePtr(notowned);
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
          string s = cpp11_std_unique_ptr.takeKlassUniquePtr(kini);
          checkCount(0);
          if (s != "KlassInheritanceInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kini))
            throw new ApplicationException("is_nullptr failed");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        cpp11_std_unique_ptr.takeKlassUniquePtr(null);
        cpp11_std_unique_ptr.takeKlassUniquePtr(cpp11_std_unique_ptr.make_null());
        checkCount(0);

        // overloaded parameters
        if (cpp11_std_unique_ptr.overloadTest() != 0)
          throw new ApplicationException("overloadTest failed");
        if (cpp11_std_unique_ptr.overloadTest(null) != 1)
          throw new ApplicationException("overloadTest failed");
        if (cpp11_std_unique_ptr.overloadTest(new Klass("over")) != 1)
          throw new ApplicationException("overloadTest failed");
        checkCount(0);


        ///// INPUT BY RVALUE REF /////
        // unique_ptr as input
        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = cpp11_std_unique_ptr.moveKlassUniquePtr(kin);
          checkCount(0);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw new ApplicationException("is_nullptr failed");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = cpp11_std_unique_ptr.moveKlassUniquePtr(kin);
          checkCount(0);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw new ApplicationException("is_nullptr failed");
          bool exception_thrown = false;
          try {
            cpp11_std_unique_ptr.moveKlassUniquePtr(kin);
          } catch (ApplicationException e) {
            if (!e.Message.Contains("Cannot release ownership as memory is not owned"))
              throw new ApplicationException("incorrect exception message");
            exception_thrown = true;
          }
          if (!exception_thrown)
              throw new ApplicationException("double usage of moveKlassUniquePtr should have been an error");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        using (Klass kin = new Klass("KlassInput")) {
            bool exception_thrown = false;
            Klass notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin);
            try {
              cpp11_std_unique_ptr.moveKlassUniquePtr(notowned);
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
          string s = cpp11_std_unique_ptr.moveKlassUniquePtr(kini);
          checkCount(0);
          if (s != "KlassInheritanceInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kini))
            throw new ApplicationException("is_nullptr failed");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        cpp11_std_unique_ptr.moveKlassUniquePtr(null);
        cpp11_std_unique_ptr.moveKlassUniquePtr(cpp11_std_unique_ptr.make_null());
        checkCount(0);

        // overloaded parameters
        if (cpp11_std_unique_ptr.moveOverloadTest() != 0)
          throw new ApplicationException("moveOverloadTest failed");
        if (cpp11_std_unique_ptr.moveOverloadTest(null) != 1)
          throw new ApplicationException("moveOverloadTest failed");
        if (cpp11_std_unique_ptr.moveOverloadTest(new Klass("over")) != 1)
          throw new ApplicationException("moveOverloadTest failed");
        checkCount(0);


        ///// INPUT BY NON-CONST LVALUE REF /////
        // unique_ptr as input
        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin);
          checkCount(0);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw new ApplicationException("is_nullptr failed");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin);
          checkCount(0);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kin))
            throw new ApplicationException("is_nullptr failed");
          bool exception_thrown = false;
          try {
            cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin);
          } catch (ApplicationException e) {
            if (!e.Message.Contains("Cannot release ownership as memory is not owned"))
              throw new ApplicationException("incorrect exception message");
            exception_thrown = true;
          }
          if (!exception_thrown)
              throw new ApplicationException("double usage of moveRefKlassUniquePtr should have been an error");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        using (Klass kin = new Klass("KlassInput")) {
            bool exception_thrown = false;
            Klass notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin);
            try {
              cpp11_std_unique_ptr.moveRefKlassUniquePtr(notowned);
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
          string s = cpp11_std_unique_ptr.moveRefKlassUniquePtr(kini);
          checkCount(0);
          if (s != "KlassInheritanceInput")
            throw new ApplicationException("Incorrect string: " + s);
          if (!cpp11_std_unique_ptr.is_nullptr(kini))
            throw new ApplicationException("is_nullptr failed");
        } // Dispose should not fail, even though already deleted
        checkCount(0);

        cpp11_std_unique_ptr.moveRefKlassUniquePtr(null);
        cpp11_std_unique_ptr.moveRefKlassUniquePtr(cpp11_std_unique_ptr.make_null());
        checkCount(0);

        // overloaded parameters
        if (cpp11_std_unique_ptr.moveRefOverloadTest() != 0)
          throw new ApplicationException("moveRefOverloadTest failed");
        if (cpp11_std_unique_ptr.moveRefOverloadTest(null) != 1)
          throw new ApplicationException("moveRefOverloadTest failed");
        if (cpp11_std_unique_ptr.moveRefOverloadTest(new Klass("over")) != 1)
          throw new ApplicationException("moveRefOverloadTest failed");
        checkCount(0);


        ///// INPUT BY CONST LVALUE REF /////
        // unique_ptr as input
        using (Klass kin = new Klass("KlassInput")) {
          checkCount(1);
          string s = cpp11_std_unique_ptr.useRefKlassUniquePtr(kin);
          checkCount(1);
          if (s != "KlassInput")
            throw new ApplicationException("Incorrect string: " + s);
        }
        checkCount(0);

        using (KlassInheritance kini = new KlassInheritance("KlassInheritanceInput")) {
          checkCount(1);
          string s = cpp11_std_unique_ptr.useRefKlassUniquePtr(kini);
          checkCount(1);
          if (s != "KlassInheritanceInput")
            throw new ApplicationException("Incorrect string: " + s);
        }
        checkCount(0);

        cpp11_std_unique_ptr.useRefKlassUniquePtr(null);
        cpp11_std_unique_ptr.useRefKlassUniquePtr(cpp11_std_unique_ptr.make_null());
        checkCount(0);

        // overloaded parameters
        if (cpp11_std_unique_ptr.useRefOverloadTest() != 0)
          throw new ApplicationException("useRefOverloadTest failed");
        if (cpp11_std_unique_ptr.useRefOverloadTest(null) != 1)
          throw new ApplicationException("useRefOverloadTest failed");
        using (Klass kin = new KlassInheritance("OverloadInput")) {
          if (cpp11_std_unique_ptr.useRefOverloadTest(kin) != 1)
            throw new ApplicationException("useRefOverloadTest failed");
          checkCount(1);
        }
        checkCount(0);


        // unique_ptr as output
        Klass k1 = cpp11_std_unique_ptr.makeKlassUniquePtr("first");
        if (k1.getLabel() != "first")
            throw new Exception("wrong object label");

        Klass k2 = cpp11_std_unique_ptr.makeKlassUniquePtr("second");
        checkCount(2);

        using (Klass k3 = cpp11_std_unique_ptr.makeKlassUniquePtr("second")) {
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

        if (cpp11_std_unique_ptr.makeNullUniquePtr() != null)
          throw new Exception("null failure");

        // unique_ptr as output (rvalue ref)
        k1 = cpp11_std_unique_ptr.makeRVRKlassUniquePtr("first");
        if (k1.getLabel() != "first")
            throw new Exception("wrong object label");
        k1 = cpp11_std_unique_ptr.makeRVRKlassUniquePtr(null);
        if (k1 != null)
            throw new Exception("not null");

        // unique_ptr as output (lvalue ref)
        k1 = cpp11_std_unique_ptr.makeRefKlassUniquePtr("lvalueref");
        if (k1.getLabel() != "lvalueref")
            throw new Exception("wrong object label");
        k1 = cpp11_std_unique_ptr.makeRefKlassUniquePtr(null);
        if (k1 != null)
            throw new Exception("not null");
    }
}
