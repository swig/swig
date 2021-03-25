import typemap_template_parms.*;

public class typemap_template_parms_runme {

  static {
    try {
	System.loadLibrary("typemap_template_parms");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Xint xint = new Xint();
    int i = 0;
    i = xint.bake();
    i = xint.make();
    i = xint.lake();
    i = xint.rake();
    i = xint.take();
  }
}
