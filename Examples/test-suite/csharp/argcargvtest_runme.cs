using System;
using argcargvtestNamespace;

public class argcargvtest_runme {

  public static void Main() {
    string[] largs = {"hi", "hola", "hello"};
    if (argcargvtest.mainc(largs) != 3)
        throw new Exception("bad main typemap");

    string[] targs = {"hi", "hola"};
    if (!argcargvtest.mainv(targs, 1).Equals("hola"))
        throw new Exception("bad main typemap");

// For dynamically typed languages we test this throws an exception or similar
// at runtime, but for C# this doesn't even compile (but we can't easily
// test for that here).
//  argcargvtest.mainv("hello", 1);

    argcargvtest.initializeApp(largs);
  }
}
