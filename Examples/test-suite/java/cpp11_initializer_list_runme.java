
import cpp11_initializer_list.*;

public class cpp11_initializer_list_runme {

  static {
    try {
	System.loadLibrary("cpp11_initializer_list");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    C c = new C(null);
    String joined = c.get_joined_string();
    if (!joined.equals("AbFab"))
      throw new RuntimeException("Wrong joined string " + joined);
  }
}
