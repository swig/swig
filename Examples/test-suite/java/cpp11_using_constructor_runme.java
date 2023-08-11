
import cpp11_using_constructor.*;
import java.lang.reflect.*;

public class cpp11_using_constructor_runme {

  static {
    try {
	System.loadLibrary("cpp11_using_constructor");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Public base constructors
    new PublicDerived1(0, "hi").meth();
    new PublicDerived2().meth();
    new PublicDerived2(0, "hi").meth();
    new PublicDerived3().meth();
    new PublicDerived3(0, "hi").meth();
    new PublicDerived4().meth();
    new PublicDerived5().meth();

    // Protected base constructors
    // Cannot test most of these as the constructors are protected
    new ProtectedDerived5();

    // Mix of public and overloaded constructors
    new MixedDerived1a(0, "hi").meth();
    new MixedDerived1a().meth();
    new MixedDerived1b(0, "hi").meth();
    new MixedDerived1b().meth();

    new MixedDerived2a(0, "hi").meth();
    new MixedDerived2a().meth();
    new MixedDerived2b(0, "hi").meth();
    new MixedDerived2b().meth();

    new MixedDerived2c(0, "hi").meth();
    new MixedDerived2c().meth();
    new MixedDerived2c(0).meth();

    new MixedDerived2d(0, "hi").meth();
    new MixedDerived2d().meth();
    new MixedDerived2d(0).meth();

    new MixedDerived3a(0, "hi").meth();
    new MixedDerived3a().meth();
    new MixedDerived3b(0, "hi").meth();
    new MixedDerived3b().meth();

    new MixedDerived3c(0, "hi").meth();
    new MixedDerived3c().meth();
    new MixedDerived3c(0).meth();

    new MixedDerived3d(0, "hi").meth();
    new MixedDerived3d().meth();
    new MixedDerived3d(0).meth();

    new MixedDerived4a(0, "hi").meth();
    new MixedDerived4a().meth();
    new MixedDerived4b(0, "hi").meth();
    new MixedDerived4b().meth();

    new MixedDerived4c().meth();
    new MixedDerived4c(0).meth();

    new MixedDerived4d().meth();
    new MixedDerived4d(0).meth();

    new MixedDerived4e().meth();

    new MixedDerived4f().meth();

    // Mix of protected base constructors and overloading
    new ProotDerived1a().meth();

    new ProotDerived1b(0, "hi").meth();
    new ProotDerived1b().meth();

    new ProotDerived1c(0, "hi").meth();
    new ProotDerived1c().meth();

    new ProotDerived1d(0).meth();
    new ProotDerived1d().meth();

    new ProotDerived1e(0).meth();
    new ProotDerived1e().meth();

    new ProotDerived2a(0, "hi").meth();

    new ProotDerived2b(0, "hi").meth();

    new ProotDerived2c(0, "hi").meth();
    new ProotDerived2c().meth();

    new ProotDerived2d(0, "hi").meth();
    new ProotDerived2d().meth();

    new ProotDerived2e(0, "hi").meth();
    new ProotDerived2e().meth();

    new ProotDerived2f(0, "hi").meth();
    new ProotDerived2f().meth();
    new ProotDerived2f(0).meth();

    // Deeper inheritance chain
    DeepBase3 db3 = new DeepBase3(11);
    db3 = new DeepBase3(11, 22);
    db3 = new DeepBase3(11, 22, 33);
    DeepProtectedBase3 dbp3 = new DeepProtectedBase3(11, 22, 33);

    // Missing base
    new HiddenDerived1();

    // Templates and public base constructors (derive from non-template)
    new TemplatePublicDerived1Int(0, "hi").meth();
    new TemplatePublicDerived2Int().meth();
    new TemplatePublicDerived2Int(0, "hi").meth();
    new TemplatePublicDerived3Int().meth();
    new TemplatePublicDerived3Int(0, "hi").meth();
    new TemplatePublicDerived4Int().meth();
    new TemplatePublicDerived5Int().meth();

    // Templates and public base constructors (derive from template)
    new TemplPublicDerived1Int(0, "hi").meth();
    new TemplPublicDerived2Int().meth();
    new TemplPublicDerived2Int(0, "hi").meth();
    new TemplPublicDerived3Int().meth();
    new TemplPublicDerived3Int(0, "hi").meth();
    new TemplPublicDerived4Int().meth();
    new TemplPublicDerived5Int().meth();
    new TemplPublicDerived6Int(0, "hi").meth();
    new TemplPublicDerived6Int().meth();

    // Templated constructors (public)
    TemplateConstructor1Base tcb = new TemplateConstructor1Base(0, "hi");
    tcb = new TemplateConstructor1Base("hi", "hi");
    tcb = new TemplateConstructor1Base(11.1, "hi");
    tcb.normal_method();
    tcb.template_method(0, "hi");
    tcb.template_method("hey", "ho");

    TemplateConstructor1Derived tcd1 = new TemplateConstructor1Derived(0, "hi");
    tcd1 = new TemplateConstructor1Derived("hi", "hi");
    tcd1 = new TemplateConstructor1Derived(11.1, "hi");
    // Not the best test as these are also in the base class, hence use also introspection below
    tcd1.normal_method();
    tcd1.template_method(0, "hi");
    tcd1.template_method("hey", "ho");

    // Templated methods
    // Introspection to make sure these are actually generated in the derived class
    try {
      TemplateConstructor1Derived.class.getDeclaredMethod("normal_method", (java.lang.Class[])null);
      TemplateConstructor1Derived.class.getDeclaredMethod("template_method", new java.lang.Class[]{String.class, String.class});
      TemplateConstructor1Derived.class.getDeclaredMethod("template_method", new java.lang.Class[]{int.class, String.class});
    } catch (NoSuchMethodException e) {
      throw new RuntimeException(e);
    }

    // Templated constructors (protected)
    TemplateConstructor2Derived tcd2 = new TemplateConstructor2Derived();
    tcd2.normal_method();
    tcd2.template_method(0, "hi");
    tcd2.template_method("hey", "ho");
  }
}
