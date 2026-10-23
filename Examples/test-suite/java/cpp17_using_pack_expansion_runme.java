import cpp17_using_pack_expansion.*;

public class cpp17_using_pack_expansion_runme {

  static {
    try {
      System.loadLibrary("cpp17_using_pack_expansion");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Direct call via %template proxy (C++17 pack expansion in a using-declaration).
    OverloadedIntDouble ov = new OverloadedIntDouble();
    if (!ov.call(7).equals("Int:7"))
      throw new RuntimeException("ov.call(7)");
    if (!ov.call(2.5).equals("Double:2.500000"))
      throw new RuntimeException("ov.call(2.5)");

    // std::visit idiom using helper functions.
    if (!cpp17_using_pack_expansion.visit_functors_int(7).equals("Int:7"))
      throw new RuntimeException("visit_functors_int(7)");
    if (!cpp17_using_pack_expansion.visit_functors_double(2.5).equals("Double:2.500000"))
      throw new RuntimeException("visit_functors_double(2.5)");

    // Pack expansion in a using-declaration with a nested qualifier 'Base<Ts>::operator()...;'.
    MixedIntDouble mx = new MixedIntDouble();
    if (!mx.call(7).equals("T:7"))
      throw new RuntimeException("mx.call(7)");
    if (!mx.call(2.5).equals("T:2.500000"))
      throw new RuntimeException("mx.call(2.5)");

    // Empty pack: the using-declaration introduces no names, so the proxy class is constructible
    // but has no inherited call method.
    OverloadedEmpty emptyOverloaded = new OverloadedEmpty();
    MixedEmpty emptyMixed = new MixedEmpty();
    for (java.lang.reflect.Method m : OverloadedEmpty.class.getDeclaredMethods()) {
      if (m.getName().equals("call"))
        throw new RuntimeException("OverloadedEmpty unexpectedly exposes call()");
    }
    for (java.lang.reflect.Method m : MixedEmpty.class.getDeclaredMethods()) {
      if (m.getName().equals("call"))
        throw new RuntimeException("MixedEmpty unexpectedly exposes call()");
    }
    emptyOverloaded.delete();
    emptyMixed.delete();

    // Empty pack with member methods either side of the using-decl: the using-decl is removed
    // and before_using()/after_using() remain intact in the proxy.
    WithMembersEmpty wm = new WithMembersEmpty();
    if (!wm.before_using().equals("before"))
      throw new RuntimeException("wm.before_using()");
    if (!wm.after_using().equals("after"))
      throw new RuntimeException("wm.after_using()");
    for (java.lang.reflect.Method m : WithMembersEmpty.class.getDeclaredMethods()) {
      if (m.getName().equals("call"))
        throw new RuntimeException("WithMembersEmpty unexpectedly exposes call()");
    }
    wm.delete();
  }
}
