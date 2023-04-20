using System;
using typemap_out_optimalNamespace;

public class typemap_out_optimal_runme {

  public static void Main() {
    XX.trace = false;
    if (XX.trace)
      Console.WriteLine("calling create()");
    using (XX x = XX.create()) { }
    if (XX.trace)
      Console.WriteLine("calling createConst()");
    using (XX x = XX.createConst()) { }
  }

}

