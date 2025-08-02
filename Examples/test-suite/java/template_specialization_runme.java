import template_specialization.*;

public class template_specialization_runme {

  static {
    try {
	System.loadLibrary("template_specialization");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    UnaryFunction_double ufd = new UnaryFunction_double();
    ufd.negate();

    UnaryFunction_bool ufb = new UnaryFunction_bool();
    ufb.foo(ufb);
    ufb.not1();

    OnlySpecialized_int osi = new OnlySpecialized_int();
    osi.bar(osi);

    // Type wrapper class not proxy class is returned as primary template definition is not seen by SWIG
    SWIGTYPE_p_vfncs__OnlySpecializedT_double_t osd = template_specialization.factory(null);
  }
}
