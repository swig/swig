
import template_construct.*;

public class template_construct_runme {

  static {
    try {
	System.loadLibrary("template_construct");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Foo_int fi = new Foo_int(0);
    fi.delete();
    Foo_short fs = new Foo_short();
    fs.delete();
    fs = new Foo_short();
    fs.delete();
  }
}

