import doxygen_interface.*;
import java.util.HashMap;

public class doxygen_interface_runme {

  static {
    try {
      System.loadLibrary("doxygen_interface");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    CommentParser.parse("doxygen_interface");

    HashMap<String, String> wantedComments = new HashMap<String, String>();

    // Test that interface has documentation for the method (this is what was missing before the fix)
    wantedComments.put("doxygen_interface.MyInterface.testMethod(int)",
      "Example method to test interfaces.<br>\n" +
      "<br>\n" +
      "@param arg value<br>\n" +
      "@return another value\n" +
      "");

    // Test that SWIG-generated implementation class also has documentation for the method
    // Note: %interface_impl generates a class named MyInterfaceSwigImpl
    wantedComments.put("doxygen_interface.MyInterfaceSwigImpl.testMethod(int)",
      "Example method to test interfaces.<br>\n" +
      "<br>\n" +
      "@param arg value<br>\n" +
      "@return another value\n" +
      "");

    // Test that interface has class-level documentation
    wantedComments.put("doxygen_interface.MyInterface",
      "My interface\n" +
      "");

    // Test that SWIG-generated implementation class also has class-level documentation
    wantedComments.put("doxygen_interface.MyInterfaceSwigImpl",
      "My interface\n" +
      "");

    wantedComments.put("doxygen_interface.MyInterfaceImpl",
      "Concrete implementation for testing\n" +
      "");

    System.exit(CommentParser.check(wantedComments));
  }
}
