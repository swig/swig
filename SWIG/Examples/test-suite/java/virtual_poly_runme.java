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
    // These two natural 'copy' forms fail, only java and csharp
    // because no polymorphic return types are supported. 
    // But we can live with this restriction, more or less.
    //
    // NDouble dc = d.copy();
    // NInt ic = i.copy();

    //
    // These two 'copy' forms work, but we end  with plain NNumbers
    //
    NNumber dc = d.copy();
    NNumber ic = i.copy();

    //
    // The real problem is that there is no way to recover the 
    // original NInt or NDouble objects, even when you try
    // to use the plain and natural C++ dynamic_cast operations, 
    // since they fail:
    //
    NDouble ddc = virtual_poly.NDouble_dynamic_cast(dc);
    NInt dic = virtual_poly.NInt_dynamic_cast(ic);
  }
}
