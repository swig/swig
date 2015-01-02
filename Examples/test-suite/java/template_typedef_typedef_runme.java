import template_typedef_typedef.*;

public class template_typedef_typedef_runme {

  static {
    try {
	System.loadLibrary("template_typedef_typedef");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Object1Base ob1 = new Object1Base();
    ob1.getBlabla1(new Object1Base());
    Object2Base ob2 = new Object2Base();
    ob2.getBlabla2(new Object2Base());

    Factory factory = new Factory();
    factory.getBlabla3(new Object1Base());
    factory.getBlabla4(new Object2Base());
  }
}


