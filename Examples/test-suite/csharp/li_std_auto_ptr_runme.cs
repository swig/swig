using System;
using li_std_auto_ptrNamespace;

public class li_std_auto_ptr_runme {
    private static void WaitForGC()
    {
        System.GC.Collect(); 
        System.GC.WaitForPendingFinalizers();
        System.Threading.Thread.Sleep(10);
    }

    public static void Main()
    {
        Klass k1 = li_std_auto_ptr.makeKlassAutoPtr("first");
        if (k1.getLabel() != "first")
            throw new Exception("wrong object label");

        Klass k2 = li_std_auto_ptr.makeKlassAutoPtr("second");
        if (Klass.getTotal_count() != 2)
            throw new Exception("number of objects should be 2");

        k1 = null;
        WaitForGC();

        if (Klass.getTotal_count() != 1)
            throw new Exception("number of objects should be 1");

        if (k2.getLabel() != "second")
            throw new Exception("wrong object label");

        k2 = null;
        WaitForGC();

        if (Klass.getTotal_count() != 0)
            throw new Exception("no objects should be left");
    }
}
