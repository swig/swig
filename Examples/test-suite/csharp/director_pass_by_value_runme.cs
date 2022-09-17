using System;
using director_pass_by_valueNamespace;

public class runme
{
  private static void WaitForGC()
  {
    System.GC.Collect();
    System.GC.WaitForPendingFinalizers();
    System.Threading.Thread.Sleep(10);
  }

  static void Main()
  {
    runme r = new runme();
    r.run();
  }

  void run()
  {
    Caller caller = new Caller();
    caller.call_virtualMethod(new director_pass_by_value_Derived());
    {
      int countdown = 5;
      while (true) {
        WaitForGC();
        if (--countdown == 0)
          break;
      };
    }
    if (director_pass_by_value.has_cplusplus11())
      Counter.check_counts(1, 0, 0, 1, 0, 1); // check move constructor called and just one destructor
    // bug was the passByVal 'global' object was destroyed after the call to virtualMethod had finished.
    int ret = runme.passByVal.getVal();
    if (ret != 0x12345678)
      throw new Exception("Bad return value, got " + ret.ToString("x"));
  }
  public static PassedByValue passByVal;
}

class director_pass_by_value_Derived : DirectorPassByValueAbstractBase {
  public override void virtualMethod(PassedByValue pbv) {
    runme.passByVal = pbv;
  }
}
