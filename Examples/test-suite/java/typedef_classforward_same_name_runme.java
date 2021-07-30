
import typedef_classforward_same_name.*;

public class typedef_classforward_same_name_runme {

  static {
    try {
	    System.loadLibrary("typedef_classforward_same_name");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Foo foo = new Foo();
    foo.setX(5);
    if (typedef_classforward_same_name.extractFoo(foo) != 5)
      throw new RuntimeException("unexpected value");

    Boo boo = new Boo();
    boo.setX(5);
    if (typedef_classforward_same_name.extractBoo(boo) != 5)
      throw new RuntimeException("unexpected value");
  }
}
