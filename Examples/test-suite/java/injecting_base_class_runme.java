import injecting_base_class.*;

public class injecting_base_class_runme {

  static {
    try {
	System.loadLibrary("injecting_base_class");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(String actual, String expected) {
    if (!actual.equals(expected))
      throw new RuntimeException("expected '" + expected + "' but got '" + actual + "'");
  }

  private static void check(int actual, int expected) {
    if (actual != expected)
      throw new RuntimeException("expected " + expected + " but got " + actual);
  }

  public static void main(String argv[]) {
    // Each of these names the namespaced base Space::Base (or Space::Base2) without the namespace
    // qualifier, from within a derived class - the C++ injected class name.
    Derived d = new Derived();
    Base b = new Base("x");

    // Constructors taking the base.
    check(new Derived(b).whoami(), "Base:x");
    check(new MultiDerived(b, new Base2(5)).whoami(), "Base:x");
    check(new Derived2(b).whoami(), "Base:x");

    d.setMember(new Base("mm"));
    check(d.getMember().whoami(), "Base:mm");
    check(Derived.getSharedvar().whoami(), "Base:sharedvar");

    check(d.by_value(b).whoami(), "Base:x");
    check(d.by_pointer(b).whoami(), "Base:x");
    check(d.by_cref(b).whoami(), "Base:x");

    check(Derived.make("y").whoami(), "Base:y");
    check(Derived.static_id(b).whoami(), "Base:x");

    // Named through the derived class (Derived::Base) at namespace scope.
    check(injecting_base_class.through_derived(b).whoami(), "Base:x");

    // Multiple inheritance
    MultiDerived md = new MultiDerived();
    check(md.first(b).whoami(), "Base:x");
    check(md.second(new Base2(42)).getId(), 42);

    // Multi level inheritance: the indirect base named unqualified and through the derived class.
    Derived2 d2 = new Derived2();
    check(d2.from_grandbase(b).whoami(), "Base:x");
    check(d2.from_grandbase_qualified(b).whoami(), "Base:x");

    // Type unification: a value produced through any of the derived spellings is accepted by the
    // function taking the fully qualified Space::Base / Space::Base2.
    check(injecting_base_class.canonical(Derived.make("z")).whoami(), "Base:z");
    check(injecting_base_class.canonical(d.by_value(b)).whoami(), "Base:x");
    check(injecting_base_class.canonical2(md.second(new Base2(7))), 7);
  }
}
