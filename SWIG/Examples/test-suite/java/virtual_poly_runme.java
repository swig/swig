// virtual_poly test

import virtual_poly.*;

public class virtual_poly_runme {

  static {
    try {
	System.loadLibrary("virtual_poly");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    NDouble d = new NDouble(3.5);
    NInt i = new NInt(2);

    //
    // These two natural 'copy' forms fail because no covariant (polymorphic) return types 
    // are supported in Java. 
    //
    // NDouble dc = d.copy();
    // NInt ic = i.copy();

    //
    // Unlike C++, we have to downcast instead.
    //
    NDouble dc = (NDouble)d.copy();
    NInt ic = (NInt)i.copy();

    NDouble ddc = (NDouble)NDouble.narrow(dc);
    NInt dic = (NInt)NInt.narrow(ic);

    virtual_poly.incr(ic);
    if ( (i.get() + 1) != ic.get() )
      throw new RuntimeException("incr test failed");
  }
}
