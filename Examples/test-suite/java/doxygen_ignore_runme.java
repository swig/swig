
import doxygen_ignore.*;
import java.util.HashMap;

public class doxygen_ignore_runme {
  static {
    try {
      System.loadLibrary("doxygen_ignore");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    CommentParser.parse("doxygen_ignore");

    HashMap<String, String> wantedComments = new HashMap<String, String>();
    wantedComments.put("doxygen_ignore.doxygen_ignore.func()",
      "     A contrived example of ignoring too many commands in one comment.<br>\n" +
      " <br>\n" +
      " <br>\n" +
      " <br>\n" +
      " <br>\n" +
      "     This is specific to <i>Java</i>.<br>\n" +
      "     <br>\n" +
      " <br>\n" +
      " <br>\n" +
      " <br>\n" +
      "     Command ignored, but anything here is still included.<br>\n" +
      " <br>\n" +
      "\n" +
      "\n" +
      "\n" +
      "");

    System.exit(CommentParser.check(wantedComments));
  }
}
