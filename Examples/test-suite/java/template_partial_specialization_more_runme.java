import template_partial_specialization_more.*;

public class template_partial_specialization_more_runme {

  static {
    try {
	System.loadLibrary("template_partial_specialization_more");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // (1)
    VectInt vi = new VectInt();
    int num = new FooVectIntDouble().partially_specialized(222);
    new FooShortPtrDouble().pointer_specialize((short)0);
    vi = new FooVectVectInt().partially_specialized(vi);

    // (2)
    new HeyInts().special_hey();

    // (3)
    new XX1().special1();
    new XX2().special2();
    new XX3().special3();

    // (4)
    new PartiallerPrimary().primary((short)0, (short)0);
    new PartiallerSpecial().special(new PlainStruct(), 999, true);

    // (5)
    new LystDouble().primary(11.1, new AllocatorDouble());
    new LystShort().primary((short)0, new AllocatorShort());
    new LystPlainStructPtr().specialized1(new PlainStruct(), new AllocatorPlainStructPtr());
    new LystDoublePtrPtr().specialized2(22.2, (SWIGTYPE_p_p_double)null);
    new LystConstIntRef().specialized3(100);
    new LystConstStringRef().specialized3("hello");

    // (6)
    SpecDoubleInt d = new SpecDoubleInt();
    SpecStringInt i = new SpecStringInt();
    d.spec_specialized(12.3);
    i.spec_specialized("hi");
    template_partial_specialization_more.UseSpec1(d, d);
    template_partial_specialization_more.UseSpec2(i, i);
  }
}
