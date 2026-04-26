import cpp11_template_pack_specialization.*;

public class cpp11_template_pack_specialization_runme {
  static {
    try {
      System.loadLibrary("cpp11_template_pack_specialization");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String args[]) {
    SomeParmsInt spi = new SomeParmsInt();
    spi.primary_method();

    SomeParmsNoParms spp = new SomeParmsNoParms();
    spp.partial_method();

    SomeParmsString sps = new SomeParmsString();
    sps.partial_method("hello");

    SomeParmsIntDouble spid = new SomeParmsIntDouble();
    spid.partial_method(10, 11.1);
  }
}
