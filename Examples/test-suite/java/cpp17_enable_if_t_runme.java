import cpp17_enable_if_t.*;

public class cpp17_enable_if_t_runme {

  static {
    try {
        System.loadLibrary("cpp17_enable_if_t");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    if (cpp17_enable_if_t.enableif5(10, 20) != 30)
      throw new RuntimeException("enableif5 not working");
  }
}
