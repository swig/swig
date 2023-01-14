import template_partial_specialization_typedef.*;

public class template_partial_specialization_typedef_runme {

  static {
    try {
	System.loadLibrary("template_partial_specialization_typedef");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    double dub = 11.1;
    Concrete concrete = new Concrete();

    // One parameter tests
    new A().a();
    new B().b(); new B().bb(dub);
    new C().c(); new C().cc(dub);
    new D().d(); new D().dd(dub);
    new E().e(); new E().ee(dub);

    new F().f();
    new G().g();
    new H().h();

    new J().j();
    new K().k();
    new M().m();
    new N().n();

    new BB().b(); new BB().bb(true);
    new BBB().b(); new BBB().bb('A');
    new BBBB().b(); new BBBB().bb((short)12);
    new BBBBB().b(); new BBBBB().bb(123);

    new B1().b();
    new B2().b();
    new B3().b();
    new B4().b();

    // Two parameter tests
    new A_().a();
    new B_().b(); new B_().bbb(dub);
    new C_().c(); new C_().ccc(dub);
    new D_().d(); new D_().ddd(123);
    new E_().e();
    new F_().f();
    new G_().g();

    new C1_().c(); new C1_().ccc(concrete);
    new C2_().c(); new C2_().ccc(concrete);
    new C3_().c(); new C3_().ccc(concrete);
    new C4_().c(); new C4_().ccc(concrete);
    new B1_().b(); new B1_().bbb(concrete);
    new E1_().e();
    new E2_().e();
  }
}

