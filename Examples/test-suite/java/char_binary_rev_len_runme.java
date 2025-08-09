import char_binary_rev_len.*;

public class char_binary_rev_len_runme {

  static {
    try {
	System.loadLibrary("char_binary_rev_len");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Test t = new Test();

    String hile = "hile";
    if (t.strlen(hile) != 4)
      throw new RuntimeException("bad multi-arg typemap 1");

    String hil0 = "hil\0";
    if (t.strlen(hil0) != 4)
      throw new RuntimeException("bad multi-arg typemap 2");

    Test t2 = new Test(hile);
    if (t2.getisize() != 4)
      throw new RuntimeException("bad multi-arg typemap 3");

    if (t2.strlen("hil\0a") != 5)
      throw new RuntimeException("bad multi-arg typemap 4");
  }
}
