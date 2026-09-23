import abstract_inherit_default_args.*;

public class abstract_inherit_default_args_runme {

  static {
    try {
        System.loadLibrary("abstract_inherit_default_args");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(AbstractBase b) {
    if (b.f(1, 2) != 3)
      throw new RuntimeException("f(1, 2) failed");
    if (b.f(1) != 1)
      throw new RuntimeException("f(1) failed");
  }

  public static void main(String argv[])
  {
    check(new ConcreteDerived());
    check(new ConcreteDerivedDerived());
    check(new ConcreteDerivedDefault());
    check(new ConcreteAbstractDerived());
  }
}
