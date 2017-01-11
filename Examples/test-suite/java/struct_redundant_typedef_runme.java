
import struct_redundant_typedef.*;

public class struct_redundant_typedef_runme {

  static {
    try {
      System.loadLibrary("struct_redundant_typedef");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Foo foo = new Foo();
    foo.setX(5);
    if (struct_redundant_typedef.extract(foo) == 5) {
      // All good!
    }
  }
}
