import argcargvtest.*;

public class argcargvtest_runme {

  static {
    try {
      System.loadLibrary("argcargvtest");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    String[] largs = {"hi", "hola", "hello"};
    if (argcargvtest.mainc(largs) != 3)
        throw new RuntimeException("bad main typemap");

    String[] targs = {"hi", "hola"};
    if (!argcargvtest.mainv(targs, 0).equals("hi"))
        throw new RuntimeException("bad main typemap");
    if (!argcargvtest.mainv(targs, 1).equals("hola"))
        throw new RuntimeException("bad main typemap");
    if (!argcargvtest.mainv(targs, 2).equals("<<NULL>>"))
        throw new RuntimeException("bad main typemap");

// For dynamically typed languages we test this throws an exception or similar
// at runtime, but for Java this doesn't even compile (but we can't easily
// test for that here).
//  argcargvtest.mainv("hello", 1);

    argcargvtest.initializeApp(largs);

    // Check that an empty array works.
    String[] empty_args = {};
    if (argcargvtest.mainc(empty_args) != 0)
      throw new RuntimeException("bad main typemap");
    if (!argcargvtest.mainv(empty_args, 0).equals("<<NULL>>"))
        throw new RuntimeException("bad main typemap");

    // Check that empty strings are handled.
    String[] empty_string = {"hello", "", "world"};
    if (argcargvtest.mainc(empty_string) != 3)
      throw new RuntimeException("bad main typemap");
    if (!argcargvtest.mainv(empty_string, 0).equals("hello"))
      throw new RuntimeException("bad main typemap");
    if (!argcargvtest.mainv(empty_string, 1).equals(""))
      throw new RuntimeException("bad main typemap");
    if (!argcargvtest.mainv(empty_string, 2).equals("world"))
      throw new RuntimeException("bad main typemap");
    if (!argcargvtest.mainv(empty_string, 3).equals("<<NULL>>"))
      throw new RuntimeException("bad main typemap");
  }
}
