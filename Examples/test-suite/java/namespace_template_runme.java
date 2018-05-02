
import namespace_template.*;

public class namespace_template_runme {

  static {
    try {
      System.loadLibrary("namespace_template");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    vectorchar vc = new vectorchar();
    vectorshort vs = new vectorshort();
    vectorint vi = new vectorint();
    vectorlong vl = new vectorlong();

    vc.blah((char)10);
    vs.blah((short)10);
    vi.blah(10);
    vl.blah(10);

    vc.vectoruse(vc, vc);
    vs.vectoruse(vs, vs);
    vi.vectoruse(vi, vi);
    vl.vectoruse(vl, vl);
  }
}

