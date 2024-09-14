
import preproc_constants.*;

public class preproc_constants_runme {
  static {
    try {
        System.loadLibrary("preproc_constants");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    if (preproc_constants.CONST_STRING4 != "zer\0zer\0")
      throw new RuntimeException("Failed");
  }
}
