import template_type_collapse.*;

public class template_type_collapse_runme {

  static {
    try {
	System.loadLibrary("template_type_collapse");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    int i = 1234;
    ConsterInt ci = new DerivedConsterInt();
    ci.cccc1(i);
    ci.cccc2(i);
    ci.cccc3(i);
    ci.cccc4(i);

    DerivedConsterInt dci = new DerivedConsterInt();
    dci.dddd(i);
  }
}

