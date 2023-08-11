import template_specialization_using_declaration.*;

public class template_specialization_using_declaration_runme {

  static {
    try {
	System.loadLibrary("template_specialization_using_declaration");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    ConcreteClass cc = new ConcreteClass(11);

    // Base template tests
    BaseTemplateString bs = new BaseTemplateString();
    bs.method_primary("hi");

    BaseTemplateConcreteClass cs = new BaseTemplateConcreteClass();
    cs.method_specialization(cc);

    BaseTemplateInt bi = new BaseTemplateInt();
    bi.method_partial_specialization(22);


    // Derived template tests
    DerivedTemplateString ds = new DerivedTemplateString();
    ds.method_primary("hi");
    ds.method_primary_derived("hi");
    ds.method_primary_hidden("hi");

    DerivedTemplateConcreteClass dc = new DerivedTemplateConcreteClass();
    dc.method_specialization(cc);
    dc.method_specialization_derived(cc);
    dc.method_specialization_hidden(cc);

    DerivedTemplateInt di = new DerivedTemplateInt();
    di.method_partial_specialization(22);
    di.method_partial_specialization_derived(22);
    di.method_partial_specialization_hidden(22);
  }
}
