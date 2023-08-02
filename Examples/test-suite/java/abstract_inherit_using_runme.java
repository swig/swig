
import abstract_inherit_using.*;

public class abstract_inherit_using_runme {

  static {
    try {
        System.loadLibrary("abstract_inherit_using");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    ConcreteDerived1 cd1 = new ConcreteDerived1();
    cd1.f(1234);
    cd1.f("one");
    ConcreteDerived2 cd2 = new ConcreteDerived2();
    cd2.f(1234);
    cd2.f("one");
  }
}
