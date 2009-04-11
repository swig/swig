import global_namespace.*;

public class global_namespace_runme {

  static {
    try {
	System.loadLibrary("global_namespace");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    KlassMethods.methodA(new Klass1(), new Klass2(), new Klass3(), new Klass4(), new Klass5(), new Klass6(), new Klass7());
    KlassMethods.methodB(new Klass1(), new Klass2(), new Klass3(), new Klass4(), new Klass5(), new Klass6(), new Klass7());

    XYZMethods.methodA(new XYZ1(), new XYZ2(), new XYZ3(), new XYZ4(), new XYZ5(), new XYZ6(), new XYZ7());
    XYZMethods.methodB(new XYZ1(), new XYZ2(), new XYZ3(), new XYZ4(), new XYZ5(), new XYZ6(), new XYZ7());

    TheEnumMethods.methodA(TheEnum1.theenum1, TheEnum2.theenum2, TheEnum3.theenum3);
    TheEnumMethods.methodA(TheEnum1.theenum1, TheEnum2.theenum2, TheEnum3.theenum3);
  }
}
