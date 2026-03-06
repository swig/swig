// This tests changes the package name from cpp17_nspace_interface to cpp17_nspace_interfacePackage as javac can't seem to resolve classes and packages having the same name
public class cpp17_nspace_interface_runme {

  static {
    try {
	System.loadLibrary("cpp17_nspace_interface");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    cpp17_nspace_interfacePackage.A.Implementer impl = new cpp17_nspace_interfacePackage.A.Implementer();

    Assert(impl.Method(), "Implemented A::B::Interface::Method");
  }

  private static void Assert(String s1, String s2)
  {
    if (!s1.equals(s2))
      throw new RuntimeException("assertion failure. " + s1 + " != " + s2);
  }
}
