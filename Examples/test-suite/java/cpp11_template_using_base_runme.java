
import cpp11_template_using_base.*;

public class cpp11_template_using_base_runme {

  static {
    try {
        System.loadLibrary("cpp11_template_using_base");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(String actual, String expected) {
    if (!actual.equals(expected))
      throw new RuntimeException("expected '" + expected + "' but got '" + actual + "'");
  }

  public static void main(String argv[]) {
    DerivedInt d = new DerivedInt();
    check(d.call(7), "Int:7");

    // Inheriting constructor: using I::I; brings IntCase(int) into DerivedInt
    DerivedInt d10 = new DerivedInt(10);
    check(d10.call(7), "Int:17");

    // Inheriting constructor through a typedef-name for a template-instance base (issue #2951)
    check(new TypedefMixin().call(7), "Int:7");
    check(new TypedefMixin(10).call(7), "Int:17");

    // As above but through a typedef of a typedef (issue #2951)
    check(new TypedefChainMixin().call(7), "Int:7");
    check(new TypedefChainMixin(10).call(7), "Int:17");

    // Multiple bases plus a typedef of a typedef naming the base (issue #2951)
    TypedefChainMultiBase tcmb = new TypedefChainMultiBase();
    check(tcmb.call(7), "Int:7");
    check(tcmb.call(7.5), "Double:7.500000");
    check(new TypedefChainMultiBase(10).call(7), "Int:17");

    // Multiple bases where the base is named through a typedef-argument typedef (issue #2951)
    TypedefArgMultiBase tamb = new TypedefArgMultiBase();
    check(tamb.call(7), "Int:7");
    check(tamb.call(7.5), "Double:7.500000");
    check(new TypedefArgMultiBase(10).call(7), "Int:17");

    // Base named through a scope-qualified qualifier: using ns2951::QualBase::QualBase (issue #2951)
    check(new QualifiedBaseUsing().call(7), "Int:7");
    check(new QualifiedBaseUsing(10).call(7), "Int:17");

    // Same immediate base named through a non-fully-qualified qualifier: using QualBase::QualBase (issue #2951)
    check(new SemiQualifiedBaseUsing().call(7), "Int:7");
    check(new SemiQualifiedBaseUsing(10).call(7), "Int:17");

    // Base reached through a typedef of a typedef whose intermediate lives in a namespace (issue #2951)
    check(new NsChainUsing().call(7), "Int:7");
    check(new NsChainUsing(10).call(7), "Int:17");

    OverloadedIntDouble o = new OverloadedIntDouble();
    check(o.call(7), "Int:7");
    check(o.call(7.5), "Double:7.500000");
  }
}
