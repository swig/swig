import template_class_reuse_name.*;

public class template_class_reuse_name_runme {

  static {
    try {
      System.loadLibrary("template_class_reuse_name");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    new Bool1().tt();
    new Bool1False().ff();

    new Bool2().tt();
    new Bool2False().ff();

    new Bool3().tt();
    new Bool3False().ff();

    new Bool4().tt();
    new Bool4False().ff();


    new BoolForward1().tt();
    new BoolForward1False().ff();

    new BoolForward2().tt();
    new BoolForward2False().ff();

    new BoolForward3().tt();
    new BoolForward3False().ff();

    new BoolForward4().tt();
    new BoolForward4False().ff();


    new IntBool1().tt();
    new IntBool1False().ff();

    new IntBool2().tt();
    new IntBool2False().ff();

    new IntBool3().tt();
    new IntBool3False().ff();

    new IntBool4().tt();
    new IntBool4False().ff();

    new Duplicate2_0().n();
    new Duplicate3().n();
  }
}
