import nested_inheritance_interface.*;
import java.util.Arrays;

public class nested_inheritance_interface_runme {

  static {
    try {
      System.loadLibrary("nested_inheritance_interface");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void takeIA(IASwigInterface ia) {
  }

  public static void main(String argv[]) {
	Class[] BNInterfaces = B.N.class.getInterfaces();
    String expectedInterfacesString = "[interface nested_inheritance_interface.IASwigInterface]";
    String actualInterfacesString = Arrays.toString(BNInterfaces);
    if (!expectedInterfacesString.equals(actualInterfacesString))
      throw new RuntimeException("Expected interfaces for " + B.N.class.getName() + ": \n" + expectedInterfacesString + "\n" + "Actual interfaces: \n" + actualInterfacesString);

    if (!IASwigInterface.class.isInterface())
      throw new RuntimeException(IASwigInterface.class.getName() + " should be an interface but is not");

    // overloaded methods check
    B.N d = new B.N();
    takeIA(d);
  }
}
