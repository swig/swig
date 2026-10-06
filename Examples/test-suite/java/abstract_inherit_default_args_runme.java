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
    if (abstract_inherit_default_args.call_f(b, 1) != 1)
      throw new RuntimeException("call_f() failed");
  }

  public static void main(String argv[])
  {
    check(new ConcreteDerived());
    check(new ConcreteDerivedDerived());
    check(new ConcreteDerivedDefault());
    check(new ConcreteAbstractDerived());
  }
}
