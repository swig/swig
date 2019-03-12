
import cpp11_alias_nested_template_scoping.*;

public class cpp11_alias_nested_template_scoping_runme {

  static {
    try {
	System.loadLibrary("cpp11_alias_nested_template_scoping");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Yshort ys = new Yshort();
    short val = 0;
    val = ys.create1();
    val = ys.create2();
    val = ys.create3();
    val = ys.create4();
    val = ys.create5();
    val = ys.create6();
    val = ys.create7();

    val = ys.create13();

    val = ys.create15();
    val = ys.create16();
    val = ys.create17();
  }
}
