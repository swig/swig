
import custom_wallkw.*;

public class custom_wallkw_runme {

  static {
    try {
	System.loadLibrary("custom_wallkw");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    if (!custom_wallkw.c_clone().equals("clone"))
      throw new RuntimeException("clone_c keyword fail");
    if (!custom_wallkw._delegate().equals("delegate"))
      throw new RuntimeException("delegate keyword fail");
    if (!custom_wallkw._pass().equals("pass"))
      throw new RuntimeException("pass keyword fail");
    if (!custom_wallkw.C_alias().equals("alias"))
      throw new RuntimeException("alias keyword fail");
  }
}
