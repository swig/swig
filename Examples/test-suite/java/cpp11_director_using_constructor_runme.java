
import cpp11_director_using_constructor.*;

public class cpp11_director_using_constructor_runme {

  static {
    try {
	System.loadLibrary("cpp11_director_using_constructor");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // This is a copy of cpp11_using_constructor_runme.java for testing that the expected constructors can be called

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

  //
  // Additional tests compared to cpp11_using_constructor test
  //
  // Protected constructors, check both protected and public constructors can be called from a derived class
  class cpp11_director_using_constructor_MyProtectedBase1 extends ProtectedBase1 {
    public cpp11_director_using_constructor_MyProtectedBase1(int i, String s) {
      super(i, s);
    }
  }
  class cpp11_director_using_constructor_MyProtectedDerived1 extends ProtectedDerived1 {
    public cpp11_director_using_constructor_MyProtectedDerived1(int i, String s) {
      super(i, s);
    }
  }
  class cpp11_director_using_constructor_MyProtectedBase2 extends ProtectedBase2 {
    public cpp11_director_using_constructor_MyProtectedBase2(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProtectedBase2() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProtectedDerived2 extends ProtectedDerived2 {
    public cpp11_director_using_constructor_MyProtectedDerived2(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProtectedDerived2() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProtectedBase3 extends ProtectedBase3 {
    public cpp11_director_using_constructor_MyProtectedBase3(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProtectedBase3() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProtectedDerived3 extends ProtectedDerived3 {
    public cpp11_director_using_constructor_MyProtectedDerived3(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProtectedDerived3() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProtectedBase4 extends ProtectedBase4 {
    public cpp11_director_using_constructor_MyProtectedBase4() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProtectedDerived4 extends ProtectedDerived4 {
    public cpp11_director_using_constructor_MyProtectedDerived4() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProtectedBase5 extends ProtectedBase5 {
    public cpp11_director_using_constructor_MyProtectedBase5() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProtectedDerived5 extends ProtectedDerived5 {
    public cpp11_director_using_constructor_MyProtectedDerived5() {
      super();
    }
  }

  // Protected constructors, just check the protected constructors can be called from a derived class
  class cpp11_director_using_constructor_MyProotBase1 extends ProotBase1 {
    public cpp11_director_using_constructor_MyProotBase1(int i, String s) {
      super(i, s);
    }
  }
  class cpp11_director_using_constructor_MyProotDerived1a extends ProotDerived1a {
    public cpp11_director_using_constructor_MyProotDerived1a(int i, String s) {
      super(i, s);
    }
  }
  class cpp11_director_using_constructor_MyProotDerived1d extends ProotDerived1d {
    public cpp11_director_using_constructor_MyProotDerived1d(int i, String s) {
      super(i, s);
    }
  }
  class cpp11_director_using_constructor_MyProotDerived1e extends ProotDerived1e {
    public cpp11_director_using_constructor_MyProotDerived1e(int i, String s) {
      super(i, s);
    }
  }

  // Protected constructors, check both protected and public constructors can be called from a derived class
  class cpp11_director_using_constructor_MyProotBase2 extends ProotBase2 {
    public cpp11_director_using_constructor_MyProotBase2(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProotBase2() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProotDerived2a extends ProotDerived2a {
    public cpp11_director_using_constructor_MyProotDerived2a(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProotDerived2a() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProotDerived2b extends ProotDerived2b {
    public cpp11_director_using_constructor_MyProotDerived2b(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProotDerived2b() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProotDerived2c extends ProotDerived2c {
    public cpp11_director_using_constructor_MyProotDerived2c(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProotDerived2c() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProotDerived2d extends ProotDerived2d {
    public cpp11_director_using_constructor_MyProotDerived2d(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProotDerived2d() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProotDerived2e extends ProotDerived2e {
    public cpp11_director_using_constructor_MyProotDerived2e(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProotDerived2e() {
      super();
    }
  }
  class cpp11_director_using_constructor_MyProotDerived2f extends ProotDerived2f {
    public cpp11_director_using_constructor_MyProotDerived2f(int i, String s) {
      super(i, s);
    }
    public cpp11_director_using_constructor_MyProotDerived2f() {
      super();
    }
    public cpp11_director_using_constructor_MyProotDerived2f(int i) {
      super(i);
    }
  }


}
