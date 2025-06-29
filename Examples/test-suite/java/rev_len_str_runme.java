import rev_len_str.*;

public class rev_len_str_runme {

  static {
    try {
	System.loadLibrary("rev_len_str");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Test t = new Test();

    String hile = "hile";
    if (t.strlen(hile) != 4)
      throw new RuntimeException("bad multi-arg typemap");

    String hil0 = "hil\0";
    if (t.strlen(hil0) != 4)
      throw new RuntimeException("bad multi-arg typemap");
  }
}
