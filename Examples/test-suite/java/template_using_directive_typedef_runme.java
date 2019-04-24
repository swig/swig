
import template_using_directive_typedef.*;

public class template_using_directive_typedef_runme {

  static {
    try {
      System.loadLibrary("template_using_directive_typedef");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Vector_Obj vo = new Vector_Obj();

    Holder h = new Holder();
    h.holder_use1(vo, vo, vo);
    h.holder_use2(vo, vo, vo);
    h.holder_use3(vo, vo, vo);

    template_using_directive_typedef.tns_holder_use(vo, vo);
    template_using_directive_typedef.tns_use(vo, vo, vo);
    template_using_directive_typedef.global_holder_use(vo);
    template_using_directive_typedef.global_use(vo, vo, vo);
    template_using_directive_typedef.ns1_holder_use(vo);
    template_using_directive_typedef.ns2_holder_use(vo, vo, vo, vo);
  }
}

