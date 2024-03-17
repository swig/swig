using System;
using argcargvtestNamespace;

public class argcargvtest_runme {

  public static void Main() {
    string[] largs = {"hi", "hola", "hello"};
    if (argcargvtest.mainc(largs) != 3)
      throw new Exception("bad main typemap");

    string[] targs = {"hi", "hola"};
    if (!argcargvtest.mainv(targs, 0).Equals("hi"))
      throw new Exception("bad main typemap");
    if (!argcargvtest.mainv(targs, 1).Equals("hola"))
      throw new Exception("bad main typemap");
    if (!argcargvtest.mainv(targs, 2).Equals("<<NULL>>"))
      throw new Exception("bad main typemap");

// For dynamically typed languages we test this throws an exception or similar
// at runtime, but for C# this doesn't even compile (but we can't easily
// test for that here).
//  argcargvtest.mainv("hello", 1);

    argcargvtest.initializeApp(largs);

    // Check that an empty array works.
    string[] empty_args = {};
    if (argcargvtest.mainc(empty_args) != 0)
      throw new Exception("bad main typemap");
    if (!argcargvtest.mainv(empty_args, 0).Equals("<<NULL>>"))
      throw new Exception("bad main typemap");

    // Check that empty strings are handled.
    string[] empty_string = {"hello", "", "world"};
    if (argcargvtest.mainc(empty_string) != 3)
      throw new Exception("bad main typemap");
    if (argcargvtest.mainv(empty_string, 0) != "hello")
      throw new Exception("bad main typemap");
    if (argcargvtest.mainv(empty_string, 1) != "")
      throw new Exception("bad main typemap");
    if (argcargvtest.mainv(empty_string, 2) != "world")
      throw new Exception("bad main typemap");
    if (argcargvtest.mainv(empty_string, 3) != "<<NULL>>")
      throw new Exception("bad main typemap");
  }
}
