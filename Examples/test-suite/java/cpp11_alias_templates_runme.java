import cpp11_alias_templates.*;

public class cpp11_alias_templates_runme {

  static {
    try {
      System.loadLibrary("cpp11_alias_templates");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Box<int> and Boxed<int> resolve to Container<int> = ContainerInt.
    ContainerInt b = cpp11_alias_templates.make_box(55);
    if (b.get() != 55) throw new RuntimeException("make_box");
    b.set(77);
    if (b.get() != 77) throw new RuntimeException("ContainerInt.set/get");

    ContainerInt bb = cpp11_alias_templates.make_boxed(99);
    if (bb.get() != 99) throw new RuntimeException("make_boxed");

    // Quad<float> resolves to FixedArray<float, 4> = FixedArrayFloat4.
    FixedArrayFloat4 q = cpp11_alias_templates.make_quad();
    if (q.size() != 4) throw new RuntimeException("size");
    q.set(2, 3.5f);
    if (q.get(2) != 3.5f) throw new RuntimeException("FixedArrayFloat4.set/get");
  }
}
