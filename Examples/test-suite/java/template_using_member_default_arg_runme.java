import template_using_member_default_arg.*;

public class template_using_member_default_arg_runme {

  static {
    try {
	System.loadLibrary("template_using_member_default_arg");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    ThingADerivedInt a = new ThingADerivedInt();
    a.describeA();
    ThingBDerivedInt b = new ThingBDerivedInt();
    b.describeB();
  }
}


