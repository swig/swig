import cpp11_inheriting_constructors.*;

public class cpp11_inheriting_constructors_runme {

  static {
    try {
	System.loadLibrary("cpp11_inheriting_constructors");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Constructor inheritance via using declaration
    DerivedClass d = new DerivedClass(10);
    if (d.retrieveValue() != 10)
        throw new RuntimeException("retrieveValue() failed");

    // Member initialization at the site of the declaration
    SomeClass s = new SomeClass();
    if (s.getValue() != 5)
        throw new RuntimeException("s.value failed");
  }
}


