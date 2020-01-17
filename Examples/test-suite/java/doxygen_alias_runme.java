
import doxygen_alias.*;
import java.util.HashMap;

public class doxygen_alias_runme {
  static {
    try {
      System.loadLibrary("doxygen_alias");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    CommentParser.parse("doxygen_alias");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    wantedComments.put("doxygen_alias.doxygen_alias.make_something()",
      "     A function returning something.<br>\n" +
      " <br>\n" +
      "     @return A new object which may be null.\n" +
      "");

    System.exit(CommentParser.check(wantedComments));
  }
}
